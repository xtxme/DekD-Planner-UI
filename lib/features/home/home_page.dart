import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
import 'package:my_first_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:my_first_app/shared/widgets/assignments_card.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'package:my_first_app/features/home/presentation/home_assignment_ui_mapper.dart';
import 'package:my_first_app/features/home/presentation/providers/home_tasks_provider.dart';
import 'package:my_first_app/features/assignments/add_assignments/add_assignments.dart';
import 'package:my_first_app/features/subjects/providers.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ProviderSubscription<AsyncValue<HomeAssignmentSections>>?
  _assignmentsSubscription;
  bool _isRedirectingToLogin = false;
  bool _hasLoggedAuthError = false;
  bool _hasInitialized = false;
  int _consecutiveAuthErrors = 0;
  Timer? _authErrorResetTimer;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'HOME_DEBUG: ==================================================',
    );
    debugPrint('HOME_DEBUG: initState() called');
    debugPrint(
      'HOME_DEBUG: ==================================================',
    );

    _assignmentsSubscription = ref
        .listenManual<
          AsyncValue<HomeAssignmentSections>
        >(homeCanvasAssignmentSectionsProvider, (previous, next) {
          debugPrint('HOME_DEBUG: Assignment provider changed');
          debugPrint('HOME_DEBUG: Previous: ${previous?.valueOrNull}');
          debugPrint('HOME_DEBUG: Next: ${next.valueOrNull}');

          next.whenOrNull(
            error: (error, _) {
              debugPrint('HOME_DEBUG: Error in assignments: $error');
              debugPrint('HOME_DEBUG: Error type: ${error.runtimeType}');
              if (error is CanvasSessionExpiredException) {
                debugPrint(
                  'HOME_DEBUG: ❌ CanvasSessionExpiredException caught!',
                );

                // ✅ Only sign out after multiple consecutive auth errors
                // This prevents false positives from transient network issues
                _consecutiveAuthErrors++;
                debugPrint(
                  'HOME_DEBUG: Consecutive auth errors: $_consecutiveAuthErrors',
                );

                if (_consecutiveAuthErrors >= 3) {
                  debugPrint(
                    'HOME_DEBUG: Too many auth errors, signing out...',
                  );
                  _handleExpiredSession();
                } else {
                  // Reset the counter after 10 seconds
                  _authErrorResetTimer?.cancel();
                  _authErrorResetTimer = Timer(const Duration(seconds: 10), () {
                    _consecutiveAuthErrors = 0;
                    debugPrint('HOME_DEBUG: Auth error counter reset');
                  });

                  // Show a warning but don't sign out yet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connection issue detected. Retrying... ($_consecutiveAuthErrors/3)',
                      ),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Retry Now',
                        onPressed: () {
                          ref.invalidate(canvasAssignmentsWithUserProvider);
                          ref.invalidate(homeCanvasAssignmentSectionsProvider);
                        },
                      ),
                    ),
                  );
                }
              }
            },
            data: (_) {
              // Reset counter on success
              _consecutiveAuthErrors = 0;
              _authErrorResetTimer?.cancel();
            },
          );
        });

    _hasInitialized = true;
  }

  @override
  void dispose() {
    debugPrint('HOME_DEBUG: dispose() called');
    _authErrorResetTimer?.cancel();
    _assignmentsSubscription?.close();
    super.dispose();
  }

  Future<void> _handleExpiredSession() async {
    debugPrint('HOME_DEBUG: _handleExpiredSession() called');
    debugPrint('HOME_DEBUG: _isRedirectingToLogin = $_isRedirectingToLogin');

    if (_isRedirectingToLogin) {
      debugPrint('HOME_DEBUG: Already redirecting, skipping');
      return;
    }
    _isRedirectingToLogin = true;

    // ✅ Check mounted before using ref
    if (!mounted) {
      debugPrint('HOME_DEBUG: Widget not mounted, skipping cleanup');
      return;
    }

    try {
      debugPrint('HOME_DEBUG: Signing out...');
      await ref.read(authRemoteServiceProvider).signOut();
    } catch (e) {
      debugPrint('HOME_DEBUG: Sign out error: $e');
      // The session may already be invalid; local cleanup still needs to happen.
    }

    // ✅ Check mounted again before using ref
    if (!mounted) {
      debugPrint(
        'HOME_DEBUG: Widget not mounted after sign out, skipping cleanup',
      );
      return;
    }

    debugPrint('HOME_DEBUG: Clearing local session...');
    await ref.read(authLocalCacheDaoProvider).clearSession();

    debugPrint('HOME_DEBUG: Invalidating auth session provider...');
    ref.invalidate(authSessionProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(canvasAssignmentsWithUserProvider);
    ref.invalidate(homeCanvasAssignmentSectionsProvider);

    if (!mounted) {
      debugPrint('HOME_DEBUG: Widget not mounted, skipping navigation');
      return;
    }

    debugPrint('HOME_DEBUG: Showing snack bar and navigating to login...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your session expired. Please sign in again.'),
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  List<Widget> _buildTaskCards(List<HomeAssignmentCardData> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        AssignmentsCard(
          subject: item.subject,
          title: item.title,
          subtitle: item.subtitle,
          tagBg: item.tagBg,
          tagColor: item.tagColor,
          dueText: item.dueText,
          dueColor: item.dueColor,
          dueBg: item.dueBg,
          showDuePill: item.showDuePill,
          showShadow: item.showShadow,
        ),
      );
      if (i != items.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textTitleStrong,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.headerSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count Tasks',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textTitleStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAssignmentsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cFFF0E6DE),
      ),
      child: const Text(
        'No assignments due today or tomorrow.',
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingAssignmentsState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorAssignmentsState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cFFF0E6DE),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Canvas sync failed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textTitleStrong,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HOME_DEBUG: build() called');
    debugPrint('HOME_DEBUG: _hasInitialized = $_hasInitialized');

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final now = DateTime.now();
    final dateText = DateFormat('EEEE, MMM d').format(now).toUpperCase();
    final authSession = ref.watch(authSessionProvider);
    final profileAsync = ref.watch(profileProvider);
    final profileDisplayName = profileAsync.valueOrNull?.displayName?.trim();

    debugPrint('HOME_DEBUG: authSession.hasValue = ${authSession.hasValue}');
    debugPrint('HOME_DEBUG: authSession.value = ${authSession.value}');
    debugPrint('HOME_DEBUG: authSession.isLoading = ${authSession.isLoading}');

    // ✅ ถ้า session ยัง loading ให้แสดง loading state
    if (authSession.isLoading) {
      debugPrint('HOME_DEBUG: Showing loading state (auth session is loading)');
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authSession.hasError) {
      debugPrint(
        'HOME_DEBUG: authSessionProvider has error: ${authSession.error}',
      );
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'Could not verify session right now.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(authSessionProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ✅ ถ้าไม่มี session แต่อยู่ใน home page → redirect ไป login
    if (!authSession.hasValue || authSession.value == null) {
      if (!_hasLoggedAuthError) {
        debugPrint('HOME_DEBUG: ❌ No session found, redirecting to login');
        _hasLoggedAuthError = true;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('HOME_DEBUG: PostFrameCallback: redirecting to login');
        if (mounted && !_isRedirectingToLogin) {
          _isRedirectingToLogin = true;
          debugPrint('HOME_DEBUG: Actually navigating to login page...');
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Redirecting to login...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    debugPrint('HOME_DEBUG: ✅ Session exists, showing home page');
    _hasLoggedAuthError = false;

    final greetingName = (profileDisplayName?.isNotEmpty ?? false)
        ? profileDisplayName!
        : authSession.valueOrNull?.displayName?.trim() ?? 'Alex';
    final firstName = greetingName.split(RegExp(r'\s+')).first.trim();
    final greetingDisplayName = firstName.isNotEmpty ? firstName : 'Alex';
    final avatarUrl = profileAsync.valueOrNull?.avatarUrl;
    final assignmentsAsync = ref.watch(homeCanvasAssignmentSectionsProvider);
    // ดึงรายการวิชาที่มีเพื่อส่งให้หน้า Add Assignments
    final subjectsAsync = ref.watch(subjectListProvider);
    final availableSubjectNames = subjectsAsync.maybeWhen(
      data: (rows) => rows.map((e) => e.name).toList(),
      orElse: () => const <String>[],
    );

    debugPrint(
      'HOME_DEBUG: assignmentsAsync state = ${assignmentsAsync.isLoading
          ? "loading"
          : assignmentsAsync.hasError
          ? "error"
          : "data"}',
    );

    const uiMapper = HomeAssignmentUiMapper();
    final summaryText = assignmentsAsync.when(
      data: (sections) {
        final total = sections.today.length + sections.tomorrow.length;
        if (total == 0) {
          return 'No assignments due today or tomorrow.';
        }
        return 'You have $total assignments due today or tomorrow.';
      },
      loading: () => 'Loading assignments...',
      error: (error, _) => '$error',
    );

    return Scaffold(
      //วางโครงพื้นฐานของหน้า
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.headerSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.background,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(Icons.person, color: AppColors.textPrimary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 1.1,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hi, $greetingDisplayName! 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1.1,
                            color: AppColors.textTitleStrong,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: AppColors.textTitleStrong,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Ready to study?",
                          style: TextStyle(
                            fontSize: 28,
                            color: AppColors.textTitleStrong,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/icons/book.svg',
                          width: 28,
                          height: 28,
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      summaryText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    //ปุ่ม Add New / All Assignments
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // นำทางไปหน้า Add Assignment
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddAssignmentsPage(
                                    withNavBar: false,
                                    availableSubjects: availableSubjectNames,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle, size: 22),
                            label: const Text(
                              'Add New',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentSoft,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isIOS ? 10 : 12,
                                horizontal: isIOS ? 10 : 14,
                              ),
                              minimumSize: Size(0, isIOS ? 40 : 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              elevation: 6,
                              shadowColor: AppColors.accent.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(currentNavIndexProvider.notifier).state =
                                  2;
                            },
                            icon: const Icon(
                              Icons.folder_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'All Assignments',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentSoft,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isIOS ? 10 : 12,
                                horizontal: isIOS ? 10 : 14,
                              ),
                              minimumSize: Size(0, isIOS ? 40 : 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              elevation: 6,
                              shadowColor: AppColors.accent.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...assignmentsAsync.when(
                      data: (sections) {
                        final todayCards = sections.today
                            .map(
                              (assignment) => uiMapper.mapAssignment(
                                assignment,
                                isDueToday: true,
                              ),
                            )
                            .toList();

                        final tomorrowCards = sections.tomorrow
                            .map(
                              (assignment) => uiMapper.mapAssignment(
                                assignment,
                                isDueToday: false,
                              ),
                            )
                            .toList();

                        if (todayCards.isEmpty && tomorrowCards.isEmpty) {
                          return [_buildEmptyAssignmentsState()];
                        }

                        return [
                          if (todayCards.isNotEmpty) ...[
                            _buildSectionHeader(
                              title: 'Today',
                              count: todayCards.length,
                              accentColor: AppColors.accentSoft,
                            ),
                            const SizedBox(height: 12),
                            ..._buildTaskCards(todayCards),
                            const SizedBox(height: 24),
                          ],
                          if (tomorrowCards.isNotEmpty) ...[
                            _buildSectionHeader(
                              title: 'Tomorrow',
                              count: tomorrowCards.length,
                              accentColor: AppColors.border,
                            ),
                            const SizedBox(height: 12),
                            ..._buildTaskCards(tomorrowCards),
                          ],
                        ];
                      },
                      loading: () => [_buildLoadingAssignmentsState()],
                      error: (error, _) => [
                        _buildErrorAssignmentsState(
                          message: '$error',
                          onRetry: () {
                            ref.invalidate(canvasAssignmentsWithUserProvider);
                            ref.invalidate(
                              homeCanvasAssignmentSectionsProvider,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

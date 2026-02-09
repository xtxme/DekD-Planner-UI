import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import 'edit_notifi.dart';
import 'edit_profile.dart';

import 'widgets/account_section_card.dart';
import 'widgets/app_preferences_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ACCOUNT'),
                    const SizedBox(height: 12),
                    SettingsAccountCard(
                      name: 'Jane Doe',
                      email: 'jane.doe@student.com',
                      onTapProfile: () {},
                      onEditProfile: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      onSignOut: () {},
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('APP PREFERENCES'),
                    const SizedBox(height: 12),
                    SettingsPreferencesCard(
                      notificationsEnabled: _notificationsEnabled,
                      onNotificationsChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      onTapAdjustNotificationTimes: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditNotificationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 55,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.cFFF7F2EE,
        border: Border(bottom: BorderSide(color: AppColors.cFFE7DDD4)),
      ),
      child: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.cFF8B6758,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        letterSpacing: 1.2,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.cFF9A8476,
      ),
    );
  }
}

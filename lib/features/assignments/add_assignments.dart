import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../auth/widgets/auth_primary_button.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import 'models/assignment_draft.dart';
import 'widgets/add_assignment_deadline_card.dart';
import 'widgets/add_assignment_input_shell.dart';
import 'widgets/add_assignment_section_label.dart';

class AddAssignmentsPage extends ConsumerStatefulWidget {
  const AddAssignmentsPage({
    super.key,
    this.withNavBar = true,
    this.availableSubjects = _defaultSubjects,
    this.onSave,
  });

  static const List<String> _defaultSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
  ];

  final bool withNavBar;
  final List<String> availableSubjects;
  final Future<void> Function(AssignmentDraft draft)? onSave;

  @override
  ConsumerState<AddAssignmentsPage> createState() => _AddAssignmentsPageState();
}

class _AddAssignmentsPageState extends ConsumerState<AddAssignmentsPage> {
  late final TextEditingController _assignmentNameController;
  late final TextEditingController _notesController;
  late final FocusNode _assignmentNameFocusNode;
  late final FocusNode _notesFocusNode;
  late final ScrollController _scrollController;

  String? _selectedSubject;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isFormValid = false;
  bool _showValidationErrors = false;
  bool _isSaving = false;

  final GlobalKey _assignmentNameSectionKey = GlobalKey();
  final GlobalKey _subjectSectionKey = GlobalKey();
  final GlobalKey _deadlineSectionKey = GlobalKey();

  String get _title => _assignmentNameController.text.trim();

  bool get _hasUnsavedChanges =>
      _title.isNotEmpty ||
      _notesController.text.trim().isNotEmpty ||
      _selectedSubject != null ||
      _selectedDate != null ||
      _selectedTime != null;

  bool _computeFormValidity() {
    return _title.isNotEmpty &&
        _selectedSubject != null &&
        _selectedDate != null;
  }

  DateTime? get _dueAt {
    final date = _selectedDate;
    if (date == null) {
      return null;
    }

    final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void initState() {
    super.initState();
    _assignmentNameController = TextEditingController();
    _notesController = TextEditingController();
    _assignmentNameFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
    _scrollController = ScrollController();
    _assignmentNameController.addListener(_onAssignmentNameChanged);
  }

  @override
  void dispose() {
    _assignmentNameController.removeListener(_onAssignmentNameChanged);
    _assignmentNameController.dispose();
    _notesController.dispose();
    _assignmentNameFocusNode.dispose();
    _notesFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onAssignmentNameChanged() {
    final nextFormValid = _computeFormValidity();
    if (_isFormValid == nextFormValid && !_showValidationErrors) {
      return;
    }

    setState(() {
      _isFormValid = nextFormValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    final assignmentNameError = _showValidationErrors && _title.isEmpty
        ? 'Please enter assignment name.'
        : null;
    final subjectError = _showValidationErrors && _selectedSubject == null
        ? 'Please select a subject.'
        : null;
    final deadlineError = _showValidationErrors && _selectedDate == null
        ? 'Please select a due date.'
        : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        key: _assignmentNameSectionKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddAssignmentSectionLabel(
                              text: 'Assignment Name',
                            ),
                            const SizedBox(height: 10),
                            AddAssignmentInputShell(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                  controller: _assignmentNameController,
                                  focusNode: _assignmentNameFocusNode,
                                  textInputAction: TextInputAction.next,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: 'e.g., Math Problem Set 4',
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  onSubmitted: (_) =>
                                      _assignmentNameFocusNode.unfocus(),
                                ),
                              ),
                            ),
                            if (assignmentNameError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                assignmentNameError,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        key: _subjectSectionKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddAssignmentSectionLabel(text: 'Subject'),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _onSelectSubject,
                              borderRadius: BorderRadius.circular(20),
                              child: AddAssignmentInputShell(
                                minHeight: 72,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  12,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceSoft,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColors.accent,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedSubject ??
                                                'Select Subject',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: _selectedSubject == null
                                                  ? AppColors.secondaryText
                                                  : AppColors.primaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _selectedSubject == null
                                                ? 'Tap to choose a subject'
                                                : 'Selected subject',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _selectedSubject == null
                                            ? AppColors.surfaceSoft
                                            : AppColors.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _selectedSubject == null
                                            ? AppColors.secondaryText
                                            : Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (subjectError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                subjectError,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        key: _deadlineSectionKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddAssignmentSectionLabel(text: 'Deadline'),
                            const SizedBox(height: 10),
                            AddAssignmentDeadlineCard(
                              dateText: _selectedDate == null
                                  ? 'Select Date'
                                  : _formatDate(_selectedDate!),
                              timeText: _selectedTime == null
                                  ? 'Set Time'
                                  : _selectedTime!.format(context),
                              onSelectDate: _onSelectDate,
                              onSelectTime: _onSelectTime,
                            ),
                            if (deadlineError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                deadlineError,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AddAssignmentSectionLabel(text: 'Notes'),
                      const SizedBox(height: 10),
                      AddAssignmentInputShell(
                        minHeight: 150,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: GestureDetector(
                          onTap: () => _notesFocusNode.requestFocus(),
                          behavior: HitTestBehavior.opaque,
                          child: TextField(
                            controller: _notesController,
                            focusNode: _notesFocusNode,
                            minLines: 5,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText:
                                  'Add details, links, or specific\nrequirements here...',
                              hintStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Semantics(
                                button: true,
                                label: 'Save assignment',
                                child: AuthPrimaryButton(
                                  label: _isSaving
                                      ? 'Saving Assignment...'
                                      : 'Save Assignment',
                                  onPressed: _isFormValid && !_isSaving
                                      ? _onSaveAssignment
                                      : null,
                                ),
                              ),
                            ),
                            if (!_isFormValid && !_isSaving)
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _handleInvalidSaveAttempt,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: Row(
        children: [
          IconButton(
            onPressed: _onBackPressed,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'New Assignment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Future<void> _onSelectSubject() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (widget.availableSubjects.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No subjects available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Choose Subject',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                  itemCount: widget.availableSubjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final subject = widget.availableSubjects[index];
                    final isSelected = _selectedSubject == subject;
                    return Material(
                      color: isSelected
                          ? AppColors.surfaceSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        tileColor: isSelected
                            ? AppColors.surfaceSoft
                            : AppColors.surface,
                        leading: Icon(
                          Icons.book_rounded,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.secondaryText,
                        ),
                        title: Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accent,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(subject),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedSubject = selected;
      _isFormValid = _computeFormValidity();
    });
  }

  Future<void> _onSelectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      _isFormValid = _computeFormValidity();
    });
  }

  Future<void> _onSelectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
              secondary: AppColors.accent,
              onSecondary: Colors.white,
              surface: AppColors.sheetBackground,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.sheetBackground,
              dayPeriodBorderSide: const BorderSide(color: AppColors.border),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.accent;
                }
                return AppColors.lightSurface;
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return AppColors.primaryText;
              }),
              dialHandColor: AppColors.accent,
              dialBackgroundColor: AppColors.lightSurface,
              dialTextColor: AppColors.primaryText,
              hourMinuteColor: AppColors.lightSurface,
              hourMinuteTextColor: AppColors.primaryText,
              entryModeIconColor: AppColors.primaryText,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedTime = picked;
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<bool> _onWillPop() async {
    return _confirmExitIfDirty();
  }

  Future<void> _onBackPressed() async {
    final canExit = await _confirmExitIfDirty();
    if (!canExit || !mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<bool> _confirmExitIfDirty() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  void _handleInvalidSaveAttempt() {
    if (_isSaving) {
      return;
    }

    setState(() {
      _showValidationErrors = true;
      _isFormValid = _computeFormValidity();
    });

    _scrollToFirstInvalidSection();
  }

  Future<void> _scrollToFirstInvalidSection() async {
    final targetKey = _title.isEmpty
        ? _assignmentNameSectionKey
        : _selectedSubject == null
        ? _subjectSectionKey
        : _selectedDate == null
        ? _deadlineSectionKey
        : null;

    final targetContext = targetKey?.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.14,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }

    if (_title.isEmpty) {
      _assignmentNameFocusNode.requestFocus();
    }
  }

  Future<void> _onSaveAssignment() async {
    if (_isSaving) {
      return;
    }

    final currentFormValid = _computeFormValidity();
    if (!currentFormValid) {
      _handleInvalidSaveAttempt();
      return;
    }

    final dueAt = _dueAt;
    final subject = _selectedSubject;
    if (dueAt == null || subject == null) {
      _handleInvalidSaveAttempt();
      return;
    }

    setState(() {
      _showValidationErrors = true;
      _isFormValid = currentFormValid;
      _isSaving = true;
    });

    final draft = AssignmentDraft(
      title: _title,
      subject: subject,
      dueDateTime: dueAt,
      notes: _notesController.text.trim(),
    );

    try {
      if (widget.onSave != null) {
        await widget.onSave!(draft);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Assignment saved.')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save assignment. Please try again.'),
          action: SnackBarAction(label: 'Retry', onPressed: _onSaveAssignment),
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }
}

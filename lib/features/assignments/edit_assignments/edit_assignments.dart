import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import 'package:my_first_app/features/home/data/local/home_dao.dart';
import '../../subjects/add_subjects/widgets/edit_assignment_action_button.dart';
import '../../subjects/add_subjects/widgets/edit_assignment_colors.dart';
import '../../subjects/add_subjects/widgets/edit_assignment_field_shell.dart';
import '../../subjects/add_subjects/widgets/edit_assignment_header.dart';
import '../../subjects/add_subjects/widgets/edit_assignment_section_label.dart';
import '../models/assignment_draft.dart';
import '../providers.dart';

class EditAssignmentsPage extends ConsumerStatefulWidget {
  const EditAssignmentsPage({
    super.key,
    this.withNavBar = true,
    this.subjects = _defaultSubjects,
    this.initialDraft,
    this.onSave,
  });

  static const List<String> _defaultSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
  ];

  final bool withNavBar;
  final List<String> subjects;
  final AssignmentDraft? initialDraft;
  final ValueChanged<AssignmentDraft>? onSave;

  @override
  ConsumerState<EditAssignmentsPage> createState() =>
      _EditAssignmentsPageState();
}

class _EditAssignmentsPageState extends ConsumerState<EditAssignmentsPage> {
  static final AssignmentDraft _fallbackDraft = AssignmentDraft(
    title: 'Algebra Worksheet 4.2',
    subject: 'Mathematics',
    dueDateTime: DateTime(2023, 10, 24, 16, 0),
    notes:
        'Complete all problems in Chapter 4 section 2. '
        'Make sure to show your work for the polynomial division problems.\n'
        'Remember to check the back of the book for odd-numbered answers.\n'
        'Upload the scan as a single PDF.',
  );

  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final AssignmentDraft _initialSnapshot;

  late String _selectedSubject;
  DateTime _dueAt = DateTime(2023, 10, 24, 16, 0);
  bool _showValidationErrors = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  String get _title => _nameController.text.trim();
  bool get _isTitleValid => _title.isNotEmpty;
  bool get _isBusy => _isSaving || _isDeleting;
  bool get _canSave => !_isBusy && _isTitleValid;
  bool get _hasUnsavedChanges =>
      _title != _initialSnapshot.title.trim() ||
      _selectedSubject != _initialSnapshot.subject ||
      !_dueAt.isAtSameMomentAs(_initialSnapshot.dueDateTime) ||
      _notesController.text.trim() != _initialSnapshot.notes.trim();

  @override
  void initState() {
    super.initState();
    final AssignmentDraft seed =
        widget.initialDraft ??
        ref.read(assignmentDraftProvider) ??
        _fallbackDraft;
    _initialSnapshot = seed;
    _nameController = TextEditingController(text: seed.title);
    _notesController = TextEditingController(text: seed.notes);
    _selectedSubject = seed.subject;
    _dueAt = seed.dueDateTime;
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!_showValidationErrors) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final subjectOptions = {...widget.subjects, _selectedSubject}.toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final canExit = await _canExitPage();
        if (!canExit || !mounted) {
          return;
        }
        Navigator.of(this.context).pop();
      },
      child: Scaffold(
        backgroundColor: EditAssignmentColors.pageBackground,
        body: SafeArea(
          child: Column(
            children: [
              EditAssignmentHeader(
                title: 'Edit Assignment',
                onBack: _onBackPressed,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EditAssignmentSectionLabel(text: 'Assignment Name'),
                      const SizedBox(height: 10),
                      EditAssignmentFieldShell(
                        isError: _showValidationErrors && !_isTitleValid,
                        child: TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          enabled: !_isBusy,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: EditAssignmentColors.fieldText,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            hintText: 'e.g., Algebra Worksheet 4.2',
                            hintStyle: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: EditAssignmentColors.hintText,
                            ),
                          ),
                        ),
                      ),
                      if (_showValidationErrors && !_isTitleValid) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Please enter assignment name.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EditAssignmentColors.delete,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const EditAssignmentSectionLabel(text: 'Subject'),
                      const SizedBox(height: 10),
                      EditAssignmentFieldShell(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSubject,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: EditAssignmentColors.hintText,
                              size: 26,
                            ),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: EditAssignmentColors.fieldText,
                            ),
                            items: subjectOptions
                                .map(
                                  (subject) => DropdownMenuItem<String>(
                                    value: subject,
                                    child: Text(subject),
                                  ),
                                )
                                .toList(),
                            onChanged: _isBusy
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() => _selectedSubject = value);
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const EditAssignmentSectionLabel(text: 'Due Date'),
                      const SizedBox(height: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _isBusy ? null : _pickDueDateTime,
                        child: EditAssignmentFieldShell(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'MM/dd/yyyy, hh:mm a',
                                  ).format(_dueAt),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: EditAssignmentColors.fieldText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 24,
                                color: EditAssignmentColors.hintText,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const EditAssignmentSectionLabel(text: 'Notes'),
                      const SizedBox(height: 10),
                      EditAssignmentFieldShell(
                        minHeight: 208,
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                        child: TextField(
                          controller: _notesController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 6,
                          maxLines: null,
                          enabled: !_isBusy,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: EditAssignmentColors.fieldText,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      EditAssignmentActionButton(
                        label: _isSaving ? 'Saving...' : 'Save Changes',
                        icon: Icons.save_outlined,
                        isLoading: _isSaving,
                        enabled: !_isBusy,
                        onPressed: _onSaveChanges,
                      ),
                      const SizedBox(height: 14),
                      EditAssignmentActionButton(
                        label: _isDeleting
                            ? 'Deleting...'
                            : 'Delete Assignment',
                        icon: Icons.delete_rounded,
                        isPrimary: false,
                        isLoading: _isDeleting,
                        enabled: !_isBusy,
                        onPressed: _onDeleteAssignment,
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

  Future<void> _pickDueDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      final time = pickedTime ?? TimeOfDay.fromDateTime(_dueAt);
      _dueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _onSaveChanges() async {
    if (!_canSave) {
      if (_isBusy) {
        return;
      }
      setState(() => _showValidationErrors = true);
      return;
    }

    setState(() {
      _showValidationErrors = true;
      _isSaving = true;
    });

    final currentDraft =
        widget.initialDraft ?? ref.read(assignmentDraftProvider);
    final draft = AssignmentDraft(
      id: currentDraft?.id,
      title: _nameController.text.trim(),
      subject: _selectedSubject,
      dueDateTime: _dueAt,
      notes: _notesController.text.trim(),
    );

    try {
      ref.read(assignmentDraftProvider.notifier).state = draft;
      widget.onSave?.call(draft);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(draft);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
  }

  Future<void> _onDeleteAssignment() async {
    if (_isBusy) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete assignment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final currentDraft =
        widget.initialDraft ?? ref.read(assignmentDraftProvider);

    setState(() => _isDeleting = true);
    try {
      final id = currentDraft?.id;
      if (id != null) {
        await HomeDao().delete(id);
      }
      ref.read(assignmentDraftProvider.notifier).state = null;
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Assignment deleted')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete assignment')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _isDeleting = false);
  }

  Future<void> _onBackPressed() async {
    final canExit = await _canExitPage();
    if (!canExit || !mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<bool> _canExitPage() async {
    if (_isBusy || !_hasUnsavedChanges) {
      return true;
    }
    return _confirmDiscardChanges();
  }

  Future<bool> _confirmDiscardChanges() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    return shouldDiscard ?? false;
  }
}

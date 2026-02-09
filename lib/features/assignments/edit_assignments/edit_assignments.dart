import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import '../../../shared/widgets/navbar/provider.dart';
import 'widgets/edit_assignment_action_button.dart';
import 'widgets/edit_assignment_colors.dart';
import 'widgets/edit_assignment_field_shell.dart';
import 'widgets/edit_assignment_header.dart';
import 'widgets/edit_assignment_section_label.dart';

class EditAssignmentsPage extends ConsumerStatefulWidget {
  const EditAssignmentsPage({
    super.key,
    this.withNavBar = true,
    this.subjects = _defaultSubjects,
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

  @override
  ConsumerState<EditAssignmentsPage> createState() =>
      _EditAssignmentsPageState();
}

class _EditAssignmentsPageState extends ConsumerState<EditAssignmentsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  late String _selectedSubject;
  DateTime _dueAt = DateTime(2023, 10, 24, 16, 0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Algebra Worksheet 4.2');
    _notesController = TextEditingController(
      text:
          'Complete all problems in Chapter 4 section 2. '
          'Make sure to show your work for the polynomial division problems.\n'
          'Remember to check the back of the book for odd-numbered answers.\n'
          'Upload the scan as a single PDF.',
    );
    _selectedSubject = widget.subjects.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: EditAssignmentColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            EditAssignmentHeader(
              title: 'Edit Assignment',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EditAssignmentSectionLabel(text: 'Assignment Name'),
                    const SizedBox(height: 12),
                    EditAssignmentFieldShell(
                      child: TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: EditAssignmentColors.fieldText,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const EditAssignmentSectionLabel(text: 'Subject'),
                    const SizedBox(height: 12),
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
                          items: widget.subjects
                              .map(
                                (subject) => DropdownMenuItem<String>(
                                  value: subject,
                                  child: Text(subject),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _selectedSubject = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const EditAssignmentSectionLabel(text: 'Due Date'),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _pickDueDateTime,
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
                    const SizedBox(height: 26),
                    const EditAssignmentSectionLabel(text: 'Notes'),
                    const SizedBox(height: 12),
                    EditAssignmentFieldShell(
                      minHeight: 220,
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                      child: TextField(
                        controller: _notesController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 6,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 17,
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
                    const SizedBox(height: 34),
                    EditAssignmentActionButton(
                      label: 'Save Changes',
                      icon: Icons.save_outlined,
                      onPressed: _onSaveChanges,
                    ),
                    const SizedBox(height: 14),
                    EditAssignmentActionButton(
                      label: 'Delete Assignment',
                      icon: Icons.delete_rounded,
                      isPrimary: false,
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

  void _onSaveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment updated')),
    );
  }

  void _onDeleteAssignment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete action tapped')),
    );
  }
}

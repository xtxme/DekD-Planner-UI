import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import 'widgets/add_assignment_deadline_card.dart';
import 'widgets/add_assignment_input_shell.dart';
import 'widgets/add_assignment_save_button.dart';
import 'widgets/add_assignment_section_label.dart';

class AddAssignmentsPage extends ConsumerStatefulWidget {
  const AddAssignmentsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<AddAssignmentsPage> createState() => _AddAssignmentsPageState();
}

class _AddAssignmentsPageState extends ConsumerState<AddAssignmentsPage> {
  final List<String> _subjects = const [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
  ];

  late final TextEditingController _assignmentNameController;
  late final TextEditingController _notesController;

  String? _selectedSubject;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _assignmentNameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _assignmentNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AddAssignmentSectionLabel(text: 'Assignment Name'),
                    const SizedBox(height: 10),
                    AddAssignmentInputShell(
                      child: TextField(
                        controller: _assignmentNameController,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B6758),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'e.g., Math Problem Set 4',
                          hintStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA48C7E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AddAssignmentSectionLabel(text: 'Subject'),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _onSelectSubject,
                      borderRadius: BorderRadius.circular(20),
                      child: AddAssignmentInputShell(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFA48C7E),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedSubject ?? 'Select Subject',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSubject == null
                                      ? const Color(0xFFA48C7E)
                                      : const Color(0xFF8B6758),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFA48C7E),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const AddAssignmentSectionLabel(text: 'Notes'),
                    const SizedBox(height: 10),
                    AddAssignmentInputShell(
                      minHeight: 150,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        minLines: 5,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B6758),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText:
                              'Add details, links, or specific\nrequirements here...',
                          hintStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA48C7E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AddAssignmentSaveButton(onPressed: _onSaveAssignment),
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8B6758),
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
                color: Color(0xFF8B6758),
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
      backgroundColor: const Color(0xFFFDF9F4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _subjects.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return ListTile(
                title: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B6758),
                  ),
                ),
                trailing: _selectedSubject == subject
                    ? const Icon(Icons.check_rounded, color: Color(0xFFDCAF5C))
                    : null,
                onTap: () => Navigator.of(context).pop(subject),
              );
            },
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedSubject = selected;
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
              primary: Color(0xFFDCAF5C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF8B6758),
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
              primary: Color(0xFFDCAF5C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF8B6758),
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

  void _onSaveAssignment() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assignment saved.')));
  }
}

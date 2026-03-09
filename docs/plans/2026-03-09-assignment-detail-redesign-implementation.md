# Assignment Detail Page Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign assignment detail page with card-based layout, time remaining countdown, priority badges, progress indicator, and FAB actions.

**Architecture:** Replace current linear layout with card-based sections using helper functions to calculate time remaining, priority, and progress. Add floating action button with bottom sheet for actions.

**Tech Stack:** Flutter, Riverpod, existing AppColors theme

---

## Task 1: Create Helper Functions

**Files:**
- Create: `lib/features/assignments/assignments_detail/utils/assignment_detail_helpers.dart`
- Test: `test/features/assignments/assignments_detail/utils/assignment_detail_helpers_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/utils/assignment_detail_helpers.dart';

void main() {
  group('calculateTimeRemaining', () {
    test('returns "X days left" when due date is in future', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 12, 10, 0);
      
      final result = calculateTimeRemaining(dueDate, now);
      
      expect(result, '3 days left');
    });

    test('returns "X hours left" when less than 24 hours remaining', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 2, 0);
      
      final result = calculateTimeRemaining(dueDate, now);
      
      expect(result, '16 hours left');
    });

    test('returns "Overdue by X days" when past due date', () {
      final now = DateTime(2026, 3, 12, 10, 0);
      final dueDate = DateTime(2026, 3, 9, 10, 0);
      
      final result = calculateTimeRemaining(dueDate, now);
      
      expect(result, 'Overdue by 3 days');
    });
  });

  group('calculatePriority', () {
    test('returns "High" when overdue', () {
      final now = DateTime(2026, 3, 12, 10, 0);
      final dueDate = DateTime(2026, 3, 9, 10, 0);
      
      final result = calculatePriority(dueDate, 'to_do', now);
      
      expect(result, 'High');
    });

    test('returns "High" when due within 2 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 10, 0);
      
      final result = calculatePriority(dueDate, 'to_do', now);
      
      expect(result, 'High');
    });

    test('returns "Medium" when due within 7 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 14, 10, 0);
      
      final result = calculatePriority(dueDate, 'to_do', now);
      
      expect(result, 'Medium');
    });

    test('returns "Low" when due after 7 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 20, 10, 0);
      
      final result = calculatePriority(dueDate, 'to_do', now);
      
      expect(result, 'Low');
    });

    test('returns "Low" when status is completed', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 10, 0);
      
      final result = calculatePriority(dueDate, 'completed', now);
      
      expect(result, 'Low');
    });
  });

  group('calculateProgress', () {
    test('returns 0 for to_do status', () {
      expect(calculateProgress('to_do'), 0);
    });

    test('returns 50 for in_progress status', () {
      expect(calculateProgress('in_progress'), 50);
    });

    test('returns 100 for completed status', () {
      expect(calculateProgress('completed'), 100);
    });

    test('returns 0 for unknown status', () {
      expect(calculateProgress('unknown'), 0);
    });
  });

  group('shouldCollapseNotes', () {
    test('returns false for notes under 200 characters', () {
      expect(shouldCollapseNotes('Short notes'), false);
    });

    test('returns true for notes over 200 characters', () {
      final longNotes = 'a' * 201;
      expect(shouldCollapseNotes(longNotes), true);
    });

    test('returns false for empty notes', () {
      expect(shouldCollapseNotes(''), false);
    });
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/utils/assignment_detail_helpers_test.dart`

Expected: FAIL with "Error: Could not find a file named..."

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';

String calculateTimeRemaining(DateTime dueAt, [DateTime? now]) {
  final currentTime = now ?? DateTime.now();
  final difference = dueAt.difference(currentTime);
  
  if (difference.isNegative) {
    final daysOverdue = difference.inDays.abs();
    if (daysOverdue == 0) {
      final hoursOverdue = difference.inHours.abs();
      return 'Overdue by $hoursOverdue hours';
    }
    return 'Overdue by $daysOverdue days';
  }
  
  if (difference.inDays > 0) {
    return '${difference.inDays} days left';
  }
  
  final hoursLeft = difference.inHours;
  if (hoursLeft > 0) {
    return '$hoursLeft hours left';
  }
  
  final minutesLeft = difference.inMinutes;
  return '$minutesLeft minutes left';
}

String calculatePriority(DateTime dueAt, String status, [DateTime? now]) {
  if (status == 'completed') {
    return 'Low';
  }
  
  final currentTime = now ?? DateTime.now();
  final difference = dueAt.difference(currentTime);
  
  if (difference.isNegative) {
    return 'High';
  }
  
  if (difference.inDays <= 2) {
    return 'High';
  }
  
  if (difference.inDays <= 7) {
    return 'Medium';
  }
  
  return 'Low';
}

int calculateProgress(String status) {
  switch (status) {
    case 'completed':
      return 100;
    case 'in_progress':
      return 50;
    default:
      return 0;
  }
}

bool shouldCollapseNotes(String notesText) {
  return notesText.trim().length > 200;
}

Color getTimeRemainingColor(String timeRemaining) {
  if (timeRemaining.contains('Overdue')) {
    return const Color(0xFFE54A4A);
  }
  if (timeRemaining.contains('hours') || timeRemaining.contains('minutes')) {
    return const Color(0xFFE54A4A);
  }
  if (timeRemaining.contains('days')) {
    final daysStr = timeRemaining.split(' ')[0];
    final days = int.tryParse(daysStr) ?? 0;
    if (days <= 2) {
      return const Color(0xFFE0B35D);
    }
    if (days <= 7) {
      return const Color(0xFFE0B35D);
    }
    return const Color(0xFF1C9E73);
  }
  return const Color(0xFF1C9E73);
}

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return const Color(0xFFE54A4A);
    case 'Medium':
      return const Color(0xFFE0B35D);
    case 'Low':
      return const Color(0xFF1C9E73);
    default:
      return const Color(0xFF9E9E9E);
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/utils/assignment_detail_helpers_test.dart`

Expected: PASS (all tests)

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/utils/assignment_detail_helpers.dart test/features/assignments/assignments_detail/utils/assignment_detail_helpers_test.dart
git commit -m "feat: add assignment detail helper functions"
```

---

## Task 2: Create Time Remaining Badge Widget

**Files:**
- Create: `lib/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge.dart';

void main() {
  testWidgets('displays time remaining text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssignmentDetailTimeRemainingBadge(
            timeRemaining: '3 days left',
            color: Color(0xFF1C9E73),
          ),
        ),
      ),
    );

    expect(find.text('3 days left'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge_test.dart`

Expected: FAIL with "Could not find a file named..."

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';

class AssignmentDetailTimeRemainingBadge extends StatelessWidget {
  const AssignmentDetailTimeRemainingBadge({
    super.key,
    required this.timeRemaining,
    required this.color,
  });

  final String timeRemaining;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            timeRemaining,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge.dart test/features/assignments/assignments_detail/widgets/assignment_detail_time_remaining_badge_test.dart
git commit -m "feat: add time remaining badge widget"
```

---

## Task 3: Create Hero Section Widget

**Files:**
- Create: `lib/features/assignments/assignments_detail/widgets/assignment_detail_hero_section.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_hero_section_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_hero_section.dart';

void main() {
  testWidgets('displays title, time remaining, and due date', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssignmentDetailHeroSection(
            title: 'Test Assignment',
            timeRemaining: '3 days left',
            timeRemainingColor: Color(0xFF1C9E73),
            dueText: 'Due: Mar 12, 2026 | 10:00 AM',
          ),
        ),
      ),
    );

    expect(find.text('Test Assignment'), findsOneWidget);
    expect(find.text('3 days left'), findsOneWidget);
    expect(find.text('Due: Mar 12, 2026 | 10:00 AM'), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_hero_section_test.dart`

Expected: FAIL

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'assignment_detail_time_remaining_badge.dart';

class AssignmentDetailHeroSection extends StatelessWidget {
  const AssignmentDetailHeroSection({
    super.key,
    required this.title,
    required this.timeRemaining,
    required this.timeRemainingColor,
    required this.dueText,
  });

  final String title;
  final String timeRemaining;
  final Color timeRemainingColor;
  final String dueText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AssignmentDetailTimeRemainingBadge(
          timeRemaining: timeRemaining,
          color: timeRemainingColor,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_rounded,
              size: 22,
              color: AppColors.cFFE54A4A,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dueText,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cFFE54A4A,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_hero_section_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_hero_section.dart test/features/assignments/assignments_detail/widgets/assignment_detail_hero_section_test.dart
git commit -m "feat: add hero section widget"
```

---

## Task 4: Create Priority Badge Widget

**Files:**
- Create: `lib/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge.dart';

void main() {
  testWidgets('displays priority label with correct color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssignmentDetailPriorityBadge(
            priority: 'High',
            color: Color(0xFFE54A4A),
          ),
        ),
      ),
    );

    expect(find.text('High'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge_test.dart`

Expected: FAIL

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';

class AssignmentDetailPriorityBadge extends StatelessWidget {
  const AssignmentDetailPriorityBadge({
    super.key,
    required this.priority,
    required this.color,
  });

  final String priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            priority,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge.dart test/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge_test.dart
git commit -m "feat: add priority badge widget"
```

---

## Task 5: Create Progress Card Widget

**Files:**
- Create: `lib/features/assignments/assignments_detail/widgets/assignment_detail_progress_card.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_progress_card_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_progress_card.dart';

void main() {
  testWidgets('displays progress bar and percentage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssignmentDetailProgressCard(
            progressPercentage: 50,
          ),
        ),
      ),
    );

    expect(find.text('50% Complete'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows "Not Started" for 0% progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AssignmentDetailProgressCard(
            progressPercentage: 0,
          ),
        ),
      ),
    );

    expect(find.text('Not Started'), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_progress_card_test.dart`

Expected: FAIL

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailProgressCard extends StatelessWidget {
  const AssignmentDetailProgressCard({
    super.key,
    required this.progressPercentage,
  });

  final int progressPercentage;

  @override
  Widget build(BuildContext context) {
    final progressText = progressPercentage == 0
        ? 'Not Started'
        : '$progressPercentage% Complete';
    
    final progressColor = progressPercentage == 0
        ? AppColors.textSecondary
        : progressPercentage == 100
            ? const Color(0xFF1C9E73)
            : const Color(0xFF2E64D4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESS',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_progress_card_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_progress_card.dart test/features/assignments/assignments_detail/widgets/assignment_detail_progress_card_test.dart
git commit -m "feat: add progress card widget"
```

---

## Task 6: Update Quick Stats Section to Include Priority

**Files:**
- Modify: `lib/features/assignments/assignments_detail/widgets/assignment_detail_stats_section.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_stats_section_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_stats_section.dart';

void main() {
  testWidgets('displays subject, status, and priority badges', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssignmentDetailStatsSection(
            subject: 'Math',
            status: 'To Do',
            subjectIcon: Icons.calculate,
            priority: 'High',
            priorityColor: const Color(0xFFE54A4A),
          ),
        ),
      ),
    );

    expect(find.text('Math'), findsOneWidget);
    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_stats_section_test.dart`

Expected: FAIL with "The following NoSuchMethodError was thrown..."

### Step 3: Write minimal implementation

Update `assignment_detail_stats_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import 'assignment_detail_stat_card.dart';
import 'assignment_detail_priority_badge.dart';

class AssignmentDetailStatsSection extends StatelessWidget {
  const AssignmentDetailStatsSection({
    super.key,
    required this.subject,
    required this.status,
    required this.subjectIcon,
    required this.priority,
    required this.priorityColor,
  });

  final String subject;
  final String status;
  final IconData subjectIcon;
  final String priority;
  final Color priorityColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AssignmentDetailStatCard(
                icon: subjectIcon,
                iconForeground: AppColors.cFF2E64D4,
                iconBackground: AppColors.cFFDCE7FF,
                label: 'SUBJECT',
                value: subject,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AssignmentDetailStatCard(
                icon: Icons.more_horiz_rounded,
                iconForeground: AppColors.cFFE0B35D,
                iconBackground: AppColors.cFFFFF8EA,
                label: 'STATUS',
                value: status,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'PRIORITY',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            AssignmentDetailPriorityBadge(
              priority: priority,
              color: priorityColor,
            ),
          ],
        ),
      ],
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_stats_section_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_stats_section.dart test/features/assignments/assignments_detail/widgets/assignment_detail_stats_section_test.dart
git commit -m "feat: add priority to stats section"
```

---

## Task 7: Enhance Notes Card with Expand/Collapse

**Files:**
- Modify: `lib/features/assignments/assignments_detail/widgets/assignment_detail_notes_card.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_notes_card_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_notes_card.dart';

void main() {
  testWidgets('shows expand button for long notes', (tester) async {
    final longNotes = 'a' * 300;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AssignmentDetailNotesCard(text: longNotes),
          ),
        ),
      ),
    );

    expect(find.text('Show more'), findsOneWidget);
  });

  testWidgets('does not show expand button for short notes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AssignmentDetailNotesCard(text: 'Short notes'),
          ),
        ),
      ),
    );

    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('expands and collapses notes', (tester) async {
    final longNotes = 'a' * 300;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AssignmentDetailNotesCard(text: longNotes),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    
    expect(find.text('Show less'), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_notes_card_test.dart`

Expected: FAIL with "No widget found with text 'Show more'"

### Step 3: Write minimal implementation

Update `assignment_detail_notes_card.dart` to add expand/collapse:

Add at the beginning of the class:
```dart
class AssignmentDetailNotesCard extends StatefulWidget {
  const AssignmentDetailNotesCard({
    super.key,
    required this.text,
    this.htmlText,
  });

  final String text;
  final String? htmlText;

  @override
  State<AssignmentDetailNotesCard> createState() => _AssignmentDetailNotesCardState();
}

class _AssignmentDetailNotesCardState extends State<AssignmentDetailNotesCard> {
  bool _isExpanded = false;
  bool get _shouldCollapse => widget.text.trim().length > 200;
```

Update the build method to include expand/collapse button after the RichText widget.

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_notes_card_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_notes_card.dart test/features/assignments/assignments_detail/widgets/assignment_detail_notes_card_test.dart
git commit -m "feat: add expand/collapse to notes card"
```

---

## Task 8: Create FAB with Bottom Sheet

**Files:**
- Create: `lib/features/assignments/assignments_detail/widgets/assignment_detail_fab.dart`
- Test: `test/features/assignments/assignments_detail/widgets/assignment_detail_fab_test.dart`

### Step 1: Write the failing test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_fab.dart';

void main() {
  testWidgets('displays FAB button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(),
          floatingActionButton: AssignmentDetailFAB(
            onComplete: () {},
            onEdit: () {},
            onDelete: () {},
            showComplete: true,
            showEdit: true,
            showDelete: true,
          ),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
```

### Step 2: Run test to verify it fails

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_fab_test.dart`

Expected: FAIL

### Step 3: Write minimal implementation

```dart
import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailFAB extends StatelessWidget {
  const AssignmentDetailFAB({
    super.key,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showComplete = false,
    this.showEdit = false,
    this.showDelete = false,
  });

  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showComplete;
  final bool showEdit;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final hasActions = showComplete || showEdit || showDelete;
    
    if (!hasActions) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => _showActionSheet(context),
      backgroundColor: AppColors.cFF2E64D4,
      child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showComplete && onComplete != null)
                _ActionTile(
                  icon: Icons.check_rounded,
                  label: 'Mark as Complete',
                  color: const Color(0xFF1C9E73),
                  onTap: () {
                    Navigator.pop(context);
                    onComplete!();
                  },
                ),
              if (showEdit && onEdit != null)
                _ActionTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Assignment',
                  color: AppColors.cFF2E64D4,
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              if (showDelete && onDelete != null)
                _ActionTile(
                  icon: Icons.delete_rounded,
                  label: 'Delete Assignment',
                  color: const Color(0xFFE65757),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
```

### Step 4: Run test to verify it passes

Run: `flutter test test/features/assignments/assignments_detail/widgets/assignment_detail_fab_test.dart`

Expected: PASS

### Step 5: Commit

```bash
git add lib/features/assignments/assignments_detail/widgets/assignment_detail_fab.dart test/features/assignments/assignments_detail/widgets/assignment_detail_fab_test.dart
git commit -m "feat: add FAB with action bottom sheet"
```

---

## Task 9: Update Main Detail Page

**Files:**
- Modify: `lib/features/assignments/assignments_detail/assignments_detail.dart`

### Step 1: Add imports

Add at the top of the file:
```dart
import 'utils/assignment_detail_helpers.dart';
import 'widgets/assignment_detail_fab.dart';
import 'widgets/assignment_detail_hero_section.dart';
import 'widgets/assignment_detail_progress_card.dart';
```

### Step 2: Update build method

Replace the existing Column children with the new layout structure:
1. Replace `AssignmentDetailOverviewSection` with `AssignmentDetailHeroSection`
2. Add time remaining and priority calculations
3. Add progress card
4. Remove `AssignmentDetailActionButtons` from the scroll view
5. Add FAB to Scaffold

### Step 3: Test manually

Run: `flutter run`

Navigate to an assignment detail page and verify:
- Hero section displays with time remaining
- Priority badge shows correct value
- Progress card displays correctly
- FAB appears and opens bottom sheet
- All actions work

### Step 4: Commit

```bash
git add lib/features/assignments/assignments_detail/assignments_detail.dart
git commit -m "feat: update detail page with new layout"
```

---

## Task 10: Remove Old Widgets

**Files:**
- Delete: `lib/features/assignments/assignments_detail/widgets/assignment_detail_overview_section.dart`
- Delete: `lib/features/assignments/assignments_detail/widgets/assignment_detail_action_buttons.dart`
- Delete: `test/features/assignments/assignments_detail/widgets/assignment_detail_overview_section_test.dart` (if exists)
- Delete: `test/features/assignments/assignments_detail/widgets/assignment_detail_action_buttons_test.dart` (if exists)

### Step 1: Delete files

```bash
rm lib/features/assignments/assignments_detail/widgets/assignment_detail_overview_section.dart
rm lib/features/assignments/assignments_detail/widgets/assignment_detail_action_buttons.dart
```

### Step 2: Verify no broken imports

Run: `flutter analyze`

Expected: No errors

### Step 3: Commit

```bash
git add -A
git commit -m "refactor: remove old detail page widgets"
```

---

## Task 11: Final Testing & Polish

### Step 1: Run all tests

Run: `flutter test`

Expected: All tests pass

### Step 2: Run linting

Run: `flutter analyze`

Expected: No warnings or errors

### Step 3: Manual testing checklist

- [ ] Open local assignment detail - verify all new widgets display
- [ ] Open Canvas assignment detail - verify actions are hidden
- [ ] Check time remaining colors (green/yellow/red)
- [ ] Check priority badges display correctly
- [ ] Check progress bar displays and animates
- [ ] Check notes expand/collapse works
- [ ] Check FAB opens bottom sheet
- [ ] Check all actions (complete, edit, delete) work
- [ ] Test on different screen sizes
- [ ] Verify no performance issues

### Step 4: Final commit

```bash
git add -A
git commit -m "chore: final polish and testing for assignment detail redesign"
```

---

## Success Criteria

- ✅ All tests pass
- ✅ No lint warnings
- ✅ Time remaining displays with correct colors
- ✅ Priority badges show for all assignments
- ✅ Progress indicator displays correctly
- ✅ Notes section expands/collapses for long content
- ✅ FAB with bottom sheet replaces action buttons
- ✅ All existing functionality preserved
- ✅ UI feels more organized and professional

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

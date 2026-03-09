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

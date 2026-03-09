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

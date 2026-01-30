import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'models/task_item.dart';
import 'widgets/task_card.dart';
import 'package:my_first_app/shared/widgets/navbar/app_navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<TaskItem> _todayTasks = [
    TaskItem(
      subject: 'MATH',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials ',
      tagBg: Color(0xFFE7F0FF),
      tagColor: Color(0xFF2E7CF6),
      dueText: 'Due 16:00 PM',
      dueBg: Color(0xFFFFE7E7),
      dueColor: Color(0xFFE05A5A),
      showDuePill: true,
      showShadow: true,
    ),
    TaskItem(
      subject: 'HISTORY',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials ',
      tagBg: Color(0xFFFBF7F1),
      tagColor: Color(0xFFE0B66B),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
      showShadow: true,
    ),
  ];

  static const List<TaskItem> _tomorrowTasks = [
    TaskItem(
      subject: 'CHEMISTRY',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials',
      tagBg: Color(0x335FAF97),
      tagColor: Color(0xFF5FAF97),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
    ),
    TaskItem(
      subject: 'CHEMISTRY',
      title: 'Lab Report Draft',
      subtitle: 'Experiment 12: Titration',
      tagBg: Color(0x335FAF97),
      tagColor: Color(0xFF5FAF97),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
    ),
  ];

  List<Widget> _buildTaskCards(List<TaskItem> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        TaskCard(
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText =
        DateFormat('EEEE, MMM d').format(now).toUpperCase();
    return Scaffold(
      //วางโครงพื้นฐานของหน้า
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //Top Bar
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFE2D3C6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor:  Color(0xFFF7F3EC),
                        child: Icon(Icons.person, color: Color(0xFF8C6B5A)),
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
                              color: Color(0xFFA48C7E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Hi, Alex! 👋",
                            style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 1.1,
                              color: Color(0xFF826559),
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
                        color: Color(0xFFEFE2D6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Color(0xFF826559),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              //Ready to study?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          color: Color(0xFF826559),
                          fontWeight: FontWeight.w800
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
                  Text("You have 5 assignments pending this week.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA48C7E),
                    ),
                  ),
                  SizedBox(height: 20),
                  //ปุ่ม Add New / All Assignments
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle, size: 22),
                          label: const Text('Add New'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDBBA7C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            elevation: 6,
                            shadowColor: const Color(0x66B08F4F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.folder_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          label: const Text('All Assignments'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDBBA7C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            elevation: 6,
                            shadowColor: const Color(0x66B08F4F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //หัวข้อ “Today” + badge จำนวนงาน
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(0xFFDBBA7C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF826559),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2D3C6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '3 Tasks',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF826559),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildTaskCards(_todayTasks),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9C9BD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tomorrow',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF826559),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildTaskCards(_tomorrowTasks),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

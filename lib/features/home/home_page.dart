import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //วางโครงพื้นฐานของหน้า
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //Top Bar
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Color(0xFFE2D3C6),
                      child: Icon(Icons.person, color: Color(0xFF8C6B5A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MONDAY, OCT 24",
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
                    child: const Icon(Icons.notifications,
                    color: Color(0xFF826559)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              //Ready to study?
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ready to study?",
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF826559),
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/icons/book.svg',
                          width: 36,
                          height: 36,
                        ),
                        SizedBox(height: 6),
                        Text("You have 5 assignments pending this week.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFA48C7E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0E8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

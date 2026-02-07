import 'package:flutter/material.dart';

class SubjectsAddButton extends StatelessWidget {
  const SubjectsAddButton ({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned( //วางปุ่มไว้
      right: 20,
      bottom: 16,
      child: Container( //ตัวปุ่ม
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE0B35D),
          boxShadow: [
            BoxShadow(
              color: Color(0x332C2017),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 40, color: Color(0xFF876557)),
      ),
    );
  }
}
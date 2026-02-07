import 'package:flutter/material.dart';

class SubjectsHeader extends StatelessWidget {
  const SubjectsHeader({
    super.key,
    required this.onQueryChanged, //ห้ามลืมส่งฟังก์ชันมารับค่าที่ user พิมพ์
  });

  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, //ขยายความกว้างให้มากที่สุดเท่าที่พ่อ (parent) อนุญาต
      color: const Color(0xFFE2D4C7),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subjects',
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Color(0xFF826559),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFA58F83)),
                hintText: 'Search subjects...',
                hintStyle: TextStyle(
                  color: Color(0xFFB5A79E),
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

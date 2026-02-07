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
      color: const Color(0xFFE2D3C6),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subjects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7A5A4A),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF7F2EE),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: Color(0xFFA9998B),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 52,
                  minHeight: 48,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD9C6B4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD9C6B4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF7A5A4A)),
                ),
                hintText: 'Search subjects...',
                hintStyle: const TextStyle(
                  color: Color(0xFFB8A99A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

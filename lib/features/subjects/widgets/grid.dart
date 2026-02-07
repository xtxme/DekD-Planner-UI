import 'package:flutter/material.dart';

class SubjectGridItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const SubjectGridItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class SubjectsGrid extends StatelessWidget {
  const SubjectsGrid({
    super.key,
    required this.items,
  });

  final List<SubjectGridItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No subject found',
          style: TextStyle(color: Color(0xFF876557), fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) => SubjectCard(item: items[index]),
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.item,
  });

  final SubjectGridItem item;

  @override
  Widget build(BuildContext context) {
    final isInactive = item.subtitle == 'No active tasks';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2D4C7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3ECE5),
            ),
            child: Icon(item.icon, size: 36, color: const Color(0xFF876557)),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF876557),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFE9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isInactive ? const Color(0xFFB7A79D) : const Color(0xFF876557),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

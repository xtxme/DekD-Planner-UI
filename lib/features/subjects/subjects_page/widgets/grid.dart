import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

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
  const SubjectsGrid({super.key, required this.items, required this.onItemTap});

  final List<SubjectGridItem> items;
  final ValueChanged<SubjectGridItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No subject found',
          style: TextStyle(color: AppColors.cFF876557, fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.94,
      ),
      itemBuilder: (context, index) =>
          SubjectCard(item: items[index], onTap: () => onItemTap(items[index])),
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.item, required this.onTap});

  final SubjectGridItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInactive = item.subtitle == 'No active tasks';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cFFE2D4C7,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cFFF3ECE5,
                ),
                child: Icon(item.icon, size: 36, color: AppColors.cFF7A5A4A),
              ),
              const SizedBox(height: 14),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cFF7A5A4A,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cFFF5EFE9,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isInactive
                        ? AppColors.cFFB7A79D
                        : AppColors.cFF7A5A4A,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

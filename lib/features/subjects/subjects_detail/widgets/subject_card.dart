import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class SubjectInfoCard extends StatelessWidget {
  const SubjectInfoCard({
    super.key,
    required this.category,
    required this.title,
    required this.code,
    required this.teacherInfo,
    required this.description,
    required this.icon,
  });

  final String category;
  final String title;
  final String code;
  final String teacherInfo;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cFFEAE3DB,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cFFD7C8BC),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Container(width: 8, height: 260, color: AppColors.cFFE0B35D),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cFFE3DBD2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cFF9A8476,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            icon,
                            size: 34,
                            color: AppColors.cFF8B6758,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        height: 1.15,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cFF8B6758,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cFFA48C7E,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.cFFD9CEC3),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info,
                          size: 20,
                          color: AppColors.cFFA48C7E,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$teacherInfo\n$description',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              color: AppColors.cFF9A8476,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

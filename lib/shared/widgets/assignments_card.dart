import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentsCard extends StatelessWidget {
  const AssignmentsCard({
    super.key,
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.tagBg,
    required this.tagColor,
    required this.dueText,
    required this.dueColor,
    this.dueBg,
    this.showDuePill = true,
    this.showDueIcon = true,
    this.showLeadingCircle = true,
    this.showShadow = false,
  });

  final String subject;
  final String title;
  final String subtitle;
  final Color tagBg;
  final Color tagColor;
  final String dueText;
  final Color dueColor;
  final Color? dueBg;
  final bool showDuePill;
  final bool showDueIcon;
  final bool showLeadingCircle;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cFFF0E6DE),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: AppColors.c1A000000,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLeadingCircle) ...[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cFFB9A89A, width: 2),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 12,
                              color: tagColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showDuePill)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dueBg ?? AppColors.cFFF0E6DE,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showDueIcon) ...[
                              Icon(Icons.timer, size: 14, color: dueColor),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              dueText,
                              style: TextStyle(
                                fontSize: 13,
                                color: dueColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showDueIcon) ...[
                            Icon(Icons.timer, size: 14, color: dueColor),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            dueText,
                            style: TextStyle(
                              fontSize: 13,
                              color: dueColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.cFF826559,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.cFFA48C7E,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

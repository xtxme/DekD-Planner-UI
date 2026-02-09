import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class SubjectsDetailTopBar extends StatelessWidget {
  const SubjectsDetailTopBar({
    super.key,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    this.title = 'Subject Details',
  });

  final VoidCallback onBack; //ฟังก์ชันที่ไม่มีพารามิเตอร์ และ ไม่คืนค่า
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 10),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.cFF8B6758,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.cFF8B6758,
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, color: AppColors.cFF8B6758),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.cFF8B6758,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

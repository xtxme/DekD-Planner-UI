import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailActionButtons extends StatelessWidget {
  const AssignmentDetailActionButtons({
    super.key,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showComplete = true,
    this.showEdit = true,
    this.showDelete = true,
  });

  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showComplete;
  final bool showEdit;
  final bool showDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    if (onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text(
          'Are you sure you want to delete this assignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 3;
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          children: [
            if (showComplete)
              SizedBox(
                width: itemWidth,
                child: _ActionItem(
                  icon: Icons.check_rounded,
                  label: 'Complete',
                  labelColor: AppColors.cFF1C9E73,
                  iconColor: AppColors.cFF1C9E73,
                  bgColor: AppColors.cFFDFF2EA,
                  borderColor: AppColors.cFF5FAF97,
                  onTap: onComplete,
                ),
              ),
            if (showEdit)
              SizedBox(
                width: itemWidth,
                child: _ActionItem(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  labelColor: AppColors.textSecondary,
                  iconColor: AppColors.textPrimary,
                  bgColor: AppColors.surface,
                  borderColor: AppColors.border,
                  onTap: onEdit,
                ),
              ),
            if (showDelete)
              SizedBox(
                width: itemWidth,
                child: _ActionItem(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  labelColor: AppColors.cFFE65757,
                  iconColor: AppColors.cFFE65757,
                  bgColor: AppColors.surface,
                  borderColor: AppColors.cFFF9DDE0,
                  onTap: () => _confirmDelete(context),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_fab.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailFAB extends StatelessWidget {
  const AssignmentDetailFAB({
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

  @override
  Widget build(BuildContext context) {
    final hasActions = showComplete || showEdit || showDelete;

    if (!hasActions) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => _showActionSheet(context),
      backgroundColor: AppColors.cFF2E64D4,
      child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showComplete && onComplete != null)
                _ActionTile(
                  icon: Icons.check_rounded,
                  label: 'Mark as Complete',
                  color: const Color(0xFF1C9E73),
                  onTap: () {
                    Navigator.pop(context);
                    onComplete!();
                  },
                ),
              if (showEdit && onEdit != null)
                _ActionTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Assignment',
                  color: AppColors.cFF2E64D4,
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              if (showDelete && onDelete != null)
                _ActionTile(
                  icon: Icons.delete_rounded,
                  label: 'Delete Assignment',
                  color: const Color(0xFFE65757),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

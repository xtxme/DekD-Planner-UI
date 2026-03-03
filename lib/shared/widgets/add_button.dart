import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    this.onTap,
    this.right = 20,
    this.bottom = 16,
    this.size = 65,
    this.iconSize = 35,
    this.shadowBlur = 14,
    this.shadowOffset = const Offset(0, 6),
  });

  final VoidCallback? onTap;
  final double right;
  final double bottom;
  final double size;
  final double iconSize;
  final double shadowBlur;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.c332C2017,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        ),
        child: Material(
          color: AppColors.cFFE0B35D,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(Icons.add, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

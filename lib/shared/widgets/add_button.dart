import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 16,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.c332C2017,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: AppColors.cFFE0B35D,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 65,
              height: 65,
              child: Icon(Icons.add, size: 35, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

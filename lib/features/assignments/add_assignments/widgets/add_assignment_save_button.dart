import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AddAssignmentSaveButton extends StatelessWidget {
  const AddAssignmentSaveButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    return SizedBox(
      width: double.infinity,
      height: 76,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cFFDCAF5C,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.cFFE2D8CF,
          disabledForegroundColor: AppColors.cFF9A8A80,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: AppColors.cFFDCAF5C,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Save Assignment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }
}

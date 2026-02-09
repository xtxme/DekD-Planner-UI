import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class EditProfileAvatarSection extends StatelessWidget {
  const EditProfileAvatarSection({
    super.key,
    this.onTapChangePhoto,
    this.imageProvider,
  });

  final VoidCallback? onTapChangePhoto;
  final ImageProvider<Object>? imageProvider;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cFFF8F5F2, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.c22000000,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: imageProvider == null
                  ? Container(
                      color: AppColors.cFFF2C9BF,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 70,
                        color: AppColors.cFF8B6758,
                      ),
                    )
                  : Image(image: imageProvider!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onTapChangePhoto,
            style: TextButton.styleFrom(foregroundColor: AppColors.cFFDEAF5F),
            child: const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

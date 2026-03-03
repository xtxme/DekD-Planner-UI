import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class SubjectsHeader extends StatelessWidget {
  const SubjectsHeader({
    super.key,
    required this.onQueryChanged,
    this.subtitle =
        'Keep your subjects organized and import new ones from Canvas.',
  });

  final ValueChanged<String> onQueryChanged;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cFFEEE4DB,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -12,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cFFFFFCF8.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 28,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cFFFFFAF5.withValues(alpha: 0.45),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subjects',
                            style: TextStyle(
                              fontSize: 34,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cFF7A5A4A,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cFF9A8476,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.cFFFFFCF8,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cFFE7DDD4),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.c1A000000,
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.cFF7A5A4A,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cFFFFFCF8,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.c22000000,
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 56,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: true,
                      autocorrect: true,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: onQueryChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.cFFA9998B,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 56,
                          minHeight: 56,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.cFFE3DBD2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.cFFE3DBD2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.cFF8B6758,
                            width: 1.6,
                          ),
                        ),
                        hintText: 'Search subjects, codes, or Canvas courses',
                        hintStyle: const TextStyle(
                          color: AppColors.cFFB8A99A,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

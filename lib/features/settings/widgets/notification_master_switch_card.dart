import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class NotificationMasterSwitchCard extends StatelessWidget {
  const NotificationMasterSwitchCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cFFE6DBD2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.cFFF8F3EC,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cFFE8DDD3),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.cFFDEAF5F,
                size: 35,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cFF8B6758,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Turn on/off all alerts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cFFA48C7E,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.cFFDEAF5F,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.cFFD9CEC5,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

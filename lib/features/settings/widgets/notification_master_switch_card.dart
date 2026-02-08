import 'package:flutter/material.dart';

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
        border: Border.all(color: const Color(0xFFE6DBD2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3EC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8DDD3)),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFDEAF5F),
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
                      color: Color(0xFF8B6758),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Turn on/off all alerts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA48C7E),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFFDEAF5F),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD9CEC5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SettingsPreferencesCard extends StatelessWidget {
  const SettingsPreferencesCard({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    this.onTapAdjustNotificationTimes,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback? onTapAdjustNotificationTimes;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DBD2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Row(
                children: [
                  const Expanded(
                    child: _TitleSubtitle(
                      title: 'Notifications',
                      subtitle: 'Receive reminders for deadlines',
                    ),
                  ),
                  Switch(
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFFDEAF5F),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFD9CEC5),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEE4DB)),
            InkWell(
              onTap: onTapAdjustNotificationTimes,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _TitleSubtitle(
                        title: 'Adjust Notification Times',
                        subtitle: 'Customize when you get reminded',
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFC7B8AD),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleSubtitle extends StatelessWidget {
  const _TitleSubtitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8B6758),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA48C7E),
          ),
        ),
      ],
    );
  }
}

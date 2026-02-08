import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';

import 'widgets/account_section_card.dart';
import 'widgets/app_preferences_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ACCOUNT'),
                    const SizedBox(height: 12),
                    SettingsAccountCard(
                      name: 'Jane Doe',
                      email: 'jane.doe@student.com',
                      onTapProfile: () {},
                      onEditProfile: () {},
                      onSignOut: () {},
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('APP PREFERENCES'),
                    const SizedBox(height: 12),
                    SettingsPreferencesCard(
                      notificationsEnabled: _notificationsEnabled,
                      onNotificationsChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      onTapAdjustNotificationTimes: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 55,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F2EE),
        border: Border(bottom: BorderSide(color: Color(0xFFE7DDD4))),
      ),
      child: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Color(0xFF8B6758),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        letterSpacing: 1.2,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Color(0xFF9A8476),
      ),
    );
  }
}

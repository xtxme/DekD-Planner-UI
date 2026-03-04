import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/assignments/assignments_page/assignments_page.dart';
import '../../../features/home/home_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/subjects/subjects_page/subjects_page.dart';
import 'app_navbar.dart';

class NavbarShell extends ConsumerStatefulWidget {
  const NavbarShell({super.key});

  @override
  ConsumerState<NavbarShell> createState() => _NavbarShellState();
}

class _NavbarShellState extends ConsumerState<NavbarShell> {
  StreamSubscription<AuthState>? _authStateSub;

  @override
  void initState() {
    super.initState();

    // ✅ Listen to auth state changes
    _authStateSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      debugPrint('NAVBAR_DEBUG: Auth state changed: ${data.event}');

      if (data.event == AuthChangeEvent.signedOut) {
        debugPrint('NAVBAR_DEBUG: User signed out, redirecting to login');
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(),
          SubjectsPage(withNavBar: false),
          AssignmentsPage(withNavBar: false),
          SettingsPage(withNavBar: false),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(currentNavIndexProvider.notifier).state = index,
      ),
    );
  }
}

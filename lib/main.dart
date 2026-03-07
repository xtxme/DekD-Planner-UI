import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_initializer.dart';

import 'features/auth/check_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/reset_password_page.dart';
import 'features/auth/update_page.dart';
import 'features/assignments/presentation/providers/assignment_reminder_provider.dart';
import 'features/home/home_page.dart';
import 'features/assignments/assignments_page/assignments_page.dart';
import 'shared/theme/app_theme.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseInitializer.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapReminderSync());
  }

  Future<void> _bootstrapReminderSync() async {
    try {
      final syncService = ref.read(assignmentReminderSyncServiceProvider);
      await syncService.initialize();
      await syncService.resyncIfAuthenticated();
    } catch (_) {
      // Notification scheduling failures should not block app startup.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DekD Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.0,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('th'), Locale('en')],
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot': (context) => const CheckPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/password-updated': (context) => const UpdatePage(),
        '/home': (context) => const HomePage(),
        '/assignments': (context) => const AssignmentsPage(),
      },
    );
  }
}

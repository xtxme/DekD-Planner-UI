import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/check_page.dart';
import 'package:my_first_app/features/auth/reset_password_page.dart';
import 'package:my_first_app/features/auth/update_page.dart';
import 'package:my_first_app/features/subjects/subjects_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'services/database/app_database.dart';

import 'shared/widgets/navbar/navbar_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DekD Planner',
      debugShowCheckedModeBanner: false,
      home: const SubjectsPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

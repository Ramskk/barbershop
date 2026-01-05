import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

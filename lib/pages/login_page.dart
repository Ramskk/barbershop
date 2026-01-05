import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController uCtrl = TextEditingController();
  final TextEditingController pCtrl = TextEditingController();

  Future<void> login() async {
    try {
      await AuthService.login(
        username: uCtrl.text.trim(),
        password: pCtrl.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hexa Barbershop',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin Login',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: uCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pCtrl,
                    obscureText: true,
                    decoration:
                    const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('LOGIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

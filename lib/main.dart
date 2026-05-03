import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/backtest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CryptoBacktestApp());
}

class CryptoBacktestApp extends StatelessWidget {
  const CryptoBacktestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Backtest',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _SplashDecider(),
    );
  }
}

class _SplashDecider extends StatefulWidget {
  const _SplashDecider();

  @override
  State<_SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<_SplashDecider> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? '';
    final login = prefs.getString('login') ?? 'Пользователь';
    final email = prefs.getString('email') ?? '';

    if (!mounted) return;

    if (token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BacktestScreen(
            user: UserModel(
              token: token,
              login: login,
              email: email,
            ),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A',
              style: TextStyle(
                color: Color.fromARGB(255, 146, 75, 251),
                fontSize: 56,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppTheme.purple,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
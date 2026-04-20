import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../theme.dart';
import 'backtest_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (_isLogin) {
      if (email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Введите почту и пароль');
        return;
      }
    } else {
      if (name.isEmpty ||
          surname.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        setState(() => _error = 'Заполните все поля');
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSurname = prefs.getString('surname') ?? '';

      final user = _isLogin
          ? await ApiService.login(
              email: email,
              password: password,
              surname: savedSurname,
            )
          : await ApiService.register(
              name: name,
              surname: surname,
              email: email,
              password: password,
            );

      final finalName = _isLogin ? user.name : name;
      final finalSurname = _isLogin ? savedSurname : surname;

      await prefs.setString('token', user.token);
      await prefs.setString('name', finalName);
      await prefs.setString('surname', finalSurname);
      await prefs.setString('email', email);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BacktestScreen(token: user.token),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BacktestScreen(token: ''),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: AppTheme.textSecondary,
        size: 20,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A0A2E), AppTheme.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x669B59FF),
                        width: 1.5,
                      ),
                      color: AppTheme.surface,
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppTheme.purple,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CryptoBacktest',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Тестируй торговые стратегии',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _tab(
                                'Вход',
                                _isLogin,
                                () => setState(() {
                                  _isLogin = true;
                                  _error = null;
                                }),
                              ),
                              _tab(
                                'Регистрация',
                                !_isLogin,
                                () => setState(() {
                                  _isLogin = false;
                                  _error = null;
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Имя',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _surnameCtrl,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Фамилия',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Почта',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Пароль',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            if (!_loading) {
                              _submit();
                            }
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0x1AE74C3C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0x4DE74C3C),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppTheme.red,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Войти' : 'Зарегистрироваться',
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading ? null : _guestLogin,
                          child: const Text(
                            'Войти как гость',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: _loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : AppTheme.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
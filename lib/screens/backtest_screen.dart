import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/demo_data.dart';
import '../theme.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'result_screen.dart';

class BacktestScreen extends StatefulWidget {
  final UserModel user;

  const BacktestScreen({
    super.key,
    required this.user,
  });

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  String _symbol = 'BTCUSDT';
  String _timeframe = '1h';
  String _strategy = 'SMA Cross';

  bool _loading = false;

  final Map<String, String> _symbols = {
    'BTCUSDT': 'Биткоин (BTC)',
    'ETHUSDT': 'Эфириум (ETH)',
    'SOLUSDT': 'Солана (SOL)',
    'BNBUSDT': 'BNB',
    'XRPUSDT': 'XRP',
  };

  final Map<String, String> _timeframes = {
    '1m': '1 минута',
    '5m': '5 минут',
    '15m': '15 минут',
    '1h': '1 час',
    '4h': '4 часа',
    '1d': '1 день',
    '1w': '1 неделя',
    '2w': '2 недели',
    '1M': '1 месяц',
  };

  final Map<String, String> _strategies = {
    'SMA Cross': 'SMA Cross',
    'Bollinger Bands': 'Bollinger Bands',
    'RSI Oscillator': 'RSI Oscillator',
    'MACD': 'MACD',
  };

  final Map<String, TextEditingController> _controllers = {
    'start_balance': TextEditingController(text: '1000'),
    'fast_period': TextEditingController(text: '10'),
    'slow_period': TextEditingController(text: '50'),
    'window_size': TextEditingController(text: '20'),
    'deviation': TextEditingController(text: '2.0'),
    'period': TextEditingController(text: '14'),
    'buy_level': TextEditingController(text: '30'),
    'sell_level': TextEditingController(text: '70'),
    'signal_period': TextEditingController(text: '9'),
  };

  bool get _isGuest => widget.user.isGuest;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _startBalance() {
    return double.parse(
      _controllers['start_balance']!.text.replaceAll(',', '.'),
    );
  }

  String _serverStrategyName() {
    switch (_strategy) {
      case 'SMA Cross':
        return 'SMA_Cross';
      case 'Bollinger Bands':
        return 'Bollinger_Bands';
      case 'RSI Oscillator':
        return 'RSI_Oscillator';
      case 'MACD':
        return 'MACD';
      default:
        return _strategy.replaceAll(' ', '_');
    }
  }

  Map<String, dynamic> _strategyParams() {
    switch (_strategy) {
      case 'SMA Cross':
        return {
          'fast_period': int.parse(_controllers['fast_period']!.text),
          'slow_period': int.parse(_controllers['slow_period']!.text),
        };

      case 'Bollinger Bands':
        return {
          'window_size': int.parse(_controllers['window_size']!.text),
          'deviation': double.parse(
            _controllers['deviation']!.text.replaceAll(',', '.'),
          ),
        };

      case 'RSI Oscillator':
        return {
          'period': int.parse(_controllers['period']!.text),
          'buy_level': int.parse(_controllers['buy_level']!.text),
          'sell_level': int.parse(_controllers['sell_level']!.text),
        };

      case 'MACD':
        return {
          'fast_period': int.parse(_controllers['fast_period']!.text),
          'slow_period': int.parse(_controllers['slow_period']!.text),
          'signal_period': int.parse(_controllers['signal_period']!.text),
        };

      default:
        return {};
    }
  }

  String? _validateStrategy() {
    try {
      _startBalance();

      final params = _strategyParams();

      switch (_strategy) {
        case 'SMA Cross':
          final fast = params['fast_period'] as int;
          final slow = params['slow_period'] as int;

          if (fast < 5 || fast > 50) {
            return 'Быстрый период должен быть от 5 до 50';
          }
          if (slow < 50 || slow > 200) {
            return 'Медленный период должен быть от 50 до 200';
          }
          if (fast >= slow) {
            return 'Быстрый период должен быть меньше медленного';
          }
          break;

        case 'Bollinger Bands':
          final windowSize = params['window_size'] as int;
          final deviation = params['deviation'] as double;

          if (windowSize < 10 || windowSize > 100) {
            return 'Размер окна должен быть от 10 до 100';
          }
          if (deviation < 1.0 || deviation > 3.0) {
            return 'Отклонение должно быть от 1.0 до 3.0';
          }
          break;

        case 'RSI Oscillator':
          final period = params['period'] as int;
          final buy = params['buy_level'] as int;
          final sell = params['sell_level'] as int;

          if (period < 5 || period > 30) {
            return 'Период должен быть от 5 до 30';
          }
          if (buy < 10 || buy > 40) {
            return 'Уровень покупки должен быть от 10 до 40';
          }
          if (sell < 60 || sell > 90) {
            return 'Уровень продажи должен быть от 60 до 90';
          }
          if (buy >= sell) {
            return 'Уровень покупки должен быть меньше уровня продажи';
          }
          break;

        case 'MACD':
          final fast = params['fast_period'] as int;
          final slow = params['slow_period'] as int;
          final signal = params['signal_period'] as int;

          if (fast < 5 || fast > 50) {
            return 'Быстрая EMA должна быть от 5 до 50';
          }
          if (slow < 20 || slow > 100) {
            return 'Медленная EMA должна быть от 20 до 100';
          }
          if (signal < 5 || signal > 30) {
            return 'Сигнальная линия должна быть от 5 до 30';
          }
          if (fast >= slow) {
            return 'Быстрая EMA должна быть меньше медленной EMA';
          }
          break;
      }

      return null;
    } catch (_) {
      return 'Проверь параметры стратегии. Все поля должны быть числами';
    }
  }

  Future<void> _runBacktest() async {
    final error = _validateStrategy();

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (_isGuest) {
      final result = DemoData.resultFor(_symbol);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            symbol: _symbol,
            strategy: _strategy,
            isDemo: true,
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.runBacktest(
        token: widget.user.token,
        symbol: _symbol,
        timeframe: _timeframe,
        startBalance: _startBalance(),
        feePercent: 0.1,
        strategyName: _serverStrategyName(),
        params: _strategyParams(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            symbol: _symbol,
            strategy: _strategy,
            isDemo: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          token: widget.user.token,
          isDemo: _isGuest,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('login');
    await prefs.remove('email');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _dropdownMap(
    Map<String, String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: AppTheme.card,
        underline: const SizedBox(),
        style: const TextStyle(color: AppTheme.textPrimary),
        items: items.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _numberField({
    required String label,
    required String keyName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[keyName],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _strategyFields() {
    switch (_strategy) {
      case 'SMA Cross':
        return Column(
          children: [
            _numberField(
              label: 'Быстрый период (fast_period 5-50)',
              keyName: 'fast_period',
            ),
            _numberField(
              label: 'Медленный период (slow_period 50-200)',
              keyName: 'slow_period',
            ),
          ],
        );

      case 'Bollinger Bands':
        return Column(
          children: [
            _numberField(
              label: 'Размер окна (window_size 10-100)',
              keyName: 'window_size',
            ),
            _numberField(
              label: 'Отклонение (deviation 1.0-3.0)',
              keyName: 'deviation',
            ),
          ],
        );

      case 'RSI Oscillator':
        return Column(
          children: [
            _numberField(
              label: 'Период (period 5-30)',
              keyName: 'period',
            ),
            _numberField(
              label: 'Уровень покупки (buy_level 10-40)',
              keyName: 'buy_level',
            ),
            _numberField(
              label: 'Уровень продажи (sell_level 60-90)',
              keyName: 'sell_level',
            ),
          ],
        );

      case 'MACD':
        return Column(
          children: [
            _numberField(
              label: 'Быстрая EMA (fast_period 5-50)',
              keyName: 'fast_period',
            ),
            _numberField(
              label: 'Медленная EMA (slow_period 20-100)',
              keyName: 'slow_period',
            ),
            _numberField(
              label: 'Сигнальная линия (signal_period 5-30)',
              keyName: 'signal_period',
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.card,
                    child: Icon(
                      Icons.person_outline,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isGuest ? 'Гостевой режим' : widget.user.fullName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isGuest && widget.user.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.user.email,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('История'),
              onTap: () {
                Navigator.pop(context);
                _openHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выход'),
              onTap: () async {
                Navigator.pop(context);
                await _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const Text('Бэктест'),
            if (_isGuest)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x339B59FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ГОСТЬ',
                  style: TextStyle(
                    color: AppTheme.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: _CandlePainter(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Параметры стратегии',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Криптовалюта'),
                    _dropdownMap(
                      _symbols,
                      _symbol,
                      (v) {
                        if (v == null) return;
                        setState(() => _symbol = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Таймфрейм'),
                    _dropdownMap(
                      _timeframes,
                      _timeframe,
                      (v) {
                        if (v == null) return;
                        setState(() => _timeframe = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Начальный баланс'),
                    _numberField(
                      label: 'startBalance',
                      keyName: 'start_balance',
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Стратегия'),
                    _dropdownMap(
                      _strategies,
                      _strategy,
                      (v) {
                        if (v == null) return;
                        setState(() => _strategy = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    _strategyFields(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _runBacktest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Начать Бэктест',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bullPaint = Paint()
      ..color = const Color(0xFF2ECC71)
      ..strokeWidth = 2;

    final bearPaint = Paint()
      ..color = const Color(0xFFE74C3C)
      ..strokeWidth = 2;

    final linePaint = Paint()
      ..color = const Color(0xAA9B59FF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final List<List<Object>> candles = [
      [0.75, 0.55, true],
      [0.70, 0.50, false],
      [0.60, 0.40, true],
      [0.65, 0.45, false],
      [0.55, 0.35, true],
      [0.50, 0.30, false],
      [0.40, 0.20, true],
      [0.45, 0.28, false],
      [0.35, 0.15, true],
      [0.38, 0.20, false],
      [0.28, 0.10, true],
    ];

    const int count = 11;
    final double w = size.width / (count + 2);
    const double candleW = 6.0;

    for (int i = 0; i < candles.length; i++) {
      final double x = w * (i + 1.5);
      final double high = candles[i][0] as double;
      final double low = candles[i][1] as double;
      final bool isBull = candles[i][2] as bool;
      final Paint paint = isBull ? bullPaint : bearPaint;
      final double top = size.height * high;
      final double bottom = size.height * low;

      canvas.drawLine(
        Offset(x, top - 4),
        Offset(x, bottom + 4),
        paint,
      );

      canvas.drawRect(
        Rect.fromLTRB(x - candleW / 2, top, x + candleW / 2, bottom),
        Paint()..color = paint.color,
      );
    }

    final Path path = Path();
    path.moveTo(w * 1.5, size.height * 0.88);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width - w,
      size.height * 0.15,
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
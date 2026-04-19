import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/demo_data.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class BacktestScreen extends StatefulWidget {
  final String token;

  const BacktestScreen({
    super.key,
    required this.token,
  });

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
String _symbol = 'BTCUSDT';
String _timeframe = '1h';
String _strategy = 'SMA_Cross';
double _fastPeriod = 10;
double _slowPeriod = 50;
double _riskTolerance = 0.5;
bool _loading = false;

final Map<String, String> _symbols = {
  'BTCUSDT': 'Биткоин (BTC)',
  'ETHUSDT': 'Эфириум (ETH)',
  'SOLUSDT': 'Солана (SOL)',
  'BNBUSDT': 'Бинанс Коин (BNB)',
};

final Map<String, String> _timeframes = {
  '1h': '1 час',
  '4h': '4 часа',
  '1d': '1 день',
  '1w': '1 неделя',
};

final Map<String, String> _strategies = {
  'SMA_Cross': 'Пересечение SMA',
  'RSI': 'RSI (индекс силы)',
  'MACD': 'MACD',
  'Bollinger': 'Полосы Боллинджера',
};

  bool get _isGuest => widget.token.isEmpty;
  bool get _isDemo => widget.token.isEmpty;

  Future<void> _runBacktest() async {
    if (_isDemo) {
      final result = DemoData.resultFor(_symbol);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            symbol: _symbol,
            strategy: _strategy,
            isDemo: _isDemo,
          ),
        ),
      );
      return;
    }

    if (_isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Войдите в аккаунт для запуска бэктеста'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.runBacktest(
        token: widget.token,
        symbol: _symbol,
        timeframe: _timeframe,
        strategyName: _strategy,
        fastPeriod: _fastPeriod.round(),
        slowPeriod: _slowPeriod.round(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            symbol: _symbol,
            strategy: _strategy,
            isDemo: _isDemo,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
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
          token: widget.token,
          isDemo: _isDemo,
        ),
      ),
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

  Widget _chips(
    List<String> items,
    String selected,
    ValueChanged<String> onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((item) {
        final isSelected = selected == item;

        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.purple : AppTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.purple : AppTheme.border,
              ),
            ),
            child: Text(
              _symbols[item] ?? item,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider(
    String sliderName,
    double sliderValue,
    double sliderMin,
    double sliderMax,
    String sliderDisplay,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              sliderName,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.purple,
                inactiveTrackColor: AppTheme.border,
                thumbColor: AppTheme.purple,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: sliderValue,
                min: sliderMin,
                max: sliderMax,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              sliderDisplay,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
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
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(_timeframes[e] ?? e),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Бэктест'),
            if (_isDemo)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x339B59FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ДЕМО',
                  style: TextStyle(
                    color: AppTheme.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  _sectionLabel('Символ'),
                  _chips(
                    _symbols.keys.toList(),
                    _symbol,
                    (v) => setState(() => _symbol = v),
                  ),
                  const SizedBox(height: 12),
                  _sectionLabel('Стратегия'),
                  _chips(
                    _strategies.keys.toList(),
                    _strategy,
                    (v) => setState(() => _strategy = v),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    'Терпимость к риску',
                    _riskTolerance,
                    0,
                    1,
                    '${(_riskTolerance * 100).round()}%',
                    (v) => setState(() => _riskTolerance = v),
                  ),
                  _buildSlider(
                    'Быстрый период',
                    _fastPeriod,
                    2,
                    50,
                    _fastPeriod.round().toString(),
                    (v) => setState(() => _fastPeriod = v),
                  ),
                  _buildSlider(
                    'Медленный период',
                    _slowPeriod,
                    10,
                    200,
                    _slowPeriod.round().toString(),
                    (v) => setState(() => _slowPeriod = v),
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel('Таймфрейм'),
                  const SizedBox(height: 6),
                  _dropdown(
                    _timeframes.keys.toList(),
                    _timeframe,
                    (v) {
                      if (v != null) {
                        setState(() => _timeframe = v);
                      }
                    },
                  ),
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
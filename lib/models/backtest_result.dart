class BacktestResult {
  final double profitPercent;
  final int totalTrades;
  final double winRate;
  final List<EquityPoint> equityCurve;

  const BacktestResult({
    required this.profitPercent,
    required this.totalTrades,
    required this.winRate,
    required this.equityCurve,
  });

  // Для совместимости
  List<EquityPoint> get chartData => equityCurve;

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    // 🔥 поддержка 2 форматов
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : json;

    // 🔥 поддержка разных названий графика
    final chart = json['chart_data'] ??
        json['equity_curve'] ??
        [];

    return BacktestResult(
      profitPercent: (summary['profit_percent'] as num?)?.toDouble() ?? 0.0,
      totalTrades: (summary['total_trades'] as num?)?.toInt() ?? 0,
      winRate: (summary['win_rate'] as num?)?.toDouble() ?? 0.0,

      equityCurve: (chart as List)
          .map(
            (e) => EquityPoint.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class EquityPoint {
  final int time;
  final double balance;

  const EquityPoint({
    required this.time,
    required this.balance,
  });

  factory EquityPoint.fromJson(Map<String, dynamic> json) {
    return EquityPoint(
      time: (json['time'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// алиас (если где-то используется)
typedef ChartPoint = EquityPoint;
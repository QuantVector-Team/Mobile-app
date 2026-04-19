class BacktestResult {
  final double profitPercent;
  final int totalTrades;
  final double winRate;
  final List<EquityPoint> equityCurve;

  BacktestResult({
    required this.profitPercent,
    required this.totalTrades,
    required this.winRate,
    required this.equityCurve,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final equityList = json['equity_curve'] as List<dynamic>? ?? [];

    return BacktestResult(
      profitPercent: (summary['profit_percent'] as num?)?.toDouble() ?? 0.0,
      totalTrades: (summary['total_trades'] as num?)?.toInt() ?? 0,
      winRate: (summary['win_rate'] as num?)?.toDouble() ?? 0.0,
      equityCurve: equityList
          .map((item) => EquityPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EquityPoint {
  final int time;
  final double balance;

  EquityPoint({
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
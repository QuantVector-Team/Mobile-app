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
    final s = json['summary'] as Map<String, dynamic>;
    return BacktestResult(
      profitPercent: (s['profit_percent'] as num).toDouble(),
      totalTrades: s['total_trades'] as int,
      winRate: (s['win_rate'] as num).toDouble(),
      equityCurve: (json['equity_curve'] as List)
          .map((e) => EquityPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EquityPoint {
  final int time;
  final double balance;

  EquityPoint({required this.time, required this.balance});

  factory EquityPoint.fromJson(Map<String, dynamic> json) => EquityPoint(
        time: json['time'] as int,
        balance: (json['balance'] as num).toDouble(),
      );
}
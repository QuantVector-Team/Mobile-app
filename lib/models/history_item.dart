class HistoryItem {
  final int testId;
  final String date;
  final String symbol;
  final String strategyName;
  final double profitPercent;

  HistoryItem({
    required this.testId,
    required this.date,
    required this.symbol,
    required this.strategyName,
    required this.profitPercent,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      testId: (json['test_id'] as num?)?.toInt() ?? 0,
      date: (json['date'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      strategyName: (json['strategy_name'] ?? '').toString(),
      profitPercent: (json['profit_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
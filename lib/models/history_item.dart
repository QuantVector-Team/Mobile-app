class HistoryItem {
  final String date;
  final String symbol;
  final String strategyName;
  final double profitPercent;

  const HistoryItem({
    required this.date,
    required this.symbol,
    required this.strategyName,
    required this.profitPercent,
  });

  String get name => strategyName;

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      date: (json['date'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      strategyName: (json['strategy_name'] ?? '').toString(),
      profitPercent: (json['profit_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
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

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        testId: json['test_id'] as int,
        date: json['date'] as String,
        symbol: json['symbol'] as String,
        strategyName: json['strategy_name'] as String,
        profitPercent: (json['profit_percent'] as num).toDouble(),
      );
}
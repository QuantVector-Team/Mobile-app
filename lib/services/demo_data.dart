import '../models/backtest_result.dart';
import '../models/history_item.dart';
import '../models/user_model.dart';

class DemoData {
  static UserModel get demoUser => UserModel(token: 'demo_token');

  static BacktestResult get btcResult => BacktestResult(
        profitPercent: 22.5,
        totalTrades: 84,
        winRate: 62.5,
        equityCurve: [
          EquityPoint(time: 1672531200, balance: 1000.0),
          EquityPoint(time: 1672617600, balance: 1050.2),
          EquityPoint(time: 1672704000, balance: 1020.5),
          EquityPoint(time: 1672790400, balance: 1120.0),
          EquityPoint(time: 1672876800, balance: 1095.3),
          EquityPoint(time: 1672963200, balance: 1175.8),
          EquityPoint(time: 1673049600, balance: 1155.0),
          EquityPoint(time: 1673136000, balance: 1225.0),
        ],
      );

  static BacktestResult get ethResult => BacktestResult(
        profitPercent: -5.12,
        totalTrades: 41,
        winRate: 43.9,
        equityCurve: [
          EquityPoint(time: 1672531200, balance: 1000.0),
          EquityPoint(time: 1672617600, balance: 980.0),
          EquityPoint(time: 1672704000, balance: 1010.0),
          EquityPoint(time: 1672790400, balance: 990.0),
          EquityPoint(time: 1672876800, balance: 960.0),
          EquityPoint(time: 1672963200, balance: 948.8),
        ],
      );

  static List<HistoryItem> get history => [
    HistoryItem(
      testId: 101,
      date: '2024-05-20 14:30',
      symbol: 'BTCUSDT',
      strategyName: 'SMA Cross (10, 50)',
      profitPercent: 22.5,
    ),
    HistoryItem(
      testId: 102,
      date: '2024-05-19 09:15',
      symbol: 'ETHUSDT',
      strategyName: 'RSI (14)',
      profitPercent: -5.2,
    ),
  ];

  static BacktestResult resultFor(String symbol) {
    if (symbol == 'ETHUSDT') return ethResult;
    return btcResult;
  }
}
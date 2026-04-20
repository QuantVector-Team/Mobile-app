import '../models/backtest_result.dart';
import '../models/history_item.dart';
import '../models/user_model.dart';

class DemoData {
  static UserModel get demoUser => UserModel.guest();

  static BacktestResult get btcResult => const BacktestResult(
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

  static BacktestResult get ethResult => const BacktestResult(
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

  static BacktestResult get solResult => const BacktestResult(
        profitPercent: 11.8,
        totalTrades: 53,
        winRate: 57.4,
        equityCurve: [
          EquityPoint(time: 1672531200, balance: 1000.0),
          EquityPoint(time: 1672617600, balance: 1018.0),
          EquityPoint(time: 1672704000, balance: 1042.0),
          EquityPoint(time: 1672790400, balance: 1031.0),
          EquityPoint(time: 1672876800, balance: 1078.0),
          EquityPoint(time: 1672963200, balance: 1095.0),
          EquityPoint(time: 1673049600, balance: 1118.0),
        ],
      );

  static BacktestResult get bnbResult => const BacktestResult(
        profitPercent: 6.4,
        totalTrades: 36,
        winRate: 55.0,
        equityCurve: [
          EquityPoint(time: 1672531200, balance: 1000.0),
          EquityPoint(time: 1672617600, balance: 995.0),
          EquityPoint(time: 1672704000, balance: 1015.0),
          EquityPoint(time: 1672790400, balance: 1028.0),
          EquityPoint(time: 1672876800, balance: 1012.0),
          EquityPoint(time: 1672963200, balance: 1046.0),
          EquityPoint(time: 1673049600, balance: 1064.0),
        ],
      );

  static List<HistoryItem> get history => const [
        HistoryItem(
          date: '2024-05-20',
          symbol: 'BTCUSDT',
          strategyName: 'SMA_Cross',
          profitPercent: 22.5,
        ),
        HistoryItem(
          date: '2024-05-19',
          symbol: 'ETHUSDT',
          strategyName: 'RSI_Strategy',
          profitPercent: -5.2,
        ),
        HistoryItem(
          date: '2024-05-18',
          symbol: 'SOLUSDT',
          strategyName: 'MACD_Strategy',
          profitPercent: 11.8,
        ),
        HistoryItem(
          date: '2024-05-17',
          symbol: 'BNBUSDT',
          strategyName: 'Bollinger_Strategy',
          profitPercent: 6.4,
        ),
      ];

  static BacktestResult resultFor(String symbol) {
    switch (symbol) {
      case 'ETHUSDT':
        return ethResult;
      case 'SOLUSDT':
        return solResult;
      case 'BNBUSDT':
        return bnbResult;
      case 'BTCUSDT':
      default:
        return btcResult;
    }
  }
}
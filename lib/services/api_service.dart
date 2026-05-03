import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/backtest_result.dart';
import '../models/history_item.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://100.96.16.111:8080/api';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<T> _handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw Exception('Нет соединения с сервером');
    } on TimeoutException {
      throw Exception('Сервер долго не отвечает');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<UserModel> register({
    required String login,
    required String email,
    required String password,
  }) async {
    return _handleRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'platform': 'mobile',
          'auth_data': {
            'email': email,
            'password': password,
            'login': login,
          }
        }),
      );

      final data = _parseResponse(response);

      return UserModel(
        token: data['token'],
        login: login,
        email: email,
      );
    });
  }

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return _handleRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({
          'platform': 'mobile',
          'email': email,
          'password': password,
        }),
      );

      final data = _parseResponse(response);

      return UserModel(
        token: data['token'],
        login: data['login'],
        email: email,
      );
    });
  }

  static Future<BacktestResult> runBacktest({
  required String token,
  required String symbol,
  required String timeframe,
  required double startBalance,
  required double feePercent,
  required String strategyName,
  required Map<String, dynamic> params,
  }) async {
    return _handleRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/backtest'),
        headers: _headers,
        body: jsonEncode({
          'platform': 'mobile',
          'token': token,
          'need_chart': true,
          'settings': {
            'symbol': symbol,
            'timeframe': timeframe,
            'start_balance': startBalance,
            'fee_percent': feePercent,
          },
          'strategy': {
            'name': strategyName,
            'params': params,
          }
        }),
      );

      final data = _parseResponse(response);

      // 🔥 ВОТ ЭТА СТРОКА (лог сервера)
      print('BACKTEST RESPONSE: $data');

      return BacktestResult.fromJson(data);
    });
  }

  static Future<List<HistoryItem>> getHistory(String token) async {
    return _handleRequest(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/history'),
        headers: _headers,
        body: jsonEncode({
          'platform': 'mobile',
          'token': token,
          'limit': 10,
        }),
      );

      final data = _parseResponse(response);

      return (data['data'] as List)
          .map((e) => HistoryItem.fromJson(e))
          .toList();
    });
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (data['status'] == 'error') {
      throw Exception(data['message']);
    }

    return data;
  }
}
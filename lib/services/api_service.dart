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

  static Future<UserModel> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        return UserModel.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Ошибка регистрации');
    } on SocketException {
      throw Exception('Нет соединения с сервером');
    } on TimeoutException {
      throw Exception('Сервер долго не отвечает');
    } on FormatException {
      throw Exception('Некорректный ответ сервера');
    }
  }

  static Future<UserModel> login(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        return UserModel.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Ошибка входа');
    } on SocketException {
      throw Exception('Нет соединения с сервером');
    } on TimeoutException {
      throw Exception('Сервер долго не отвечает');
    } on FormatException {
      throw Exception('Некорректный ответ сервера');
    }
  }

  static Future<BacktestResult> runBacktest({
    required String token,
    required String symbol,
    required String timeframe,
    required String strategyName,
    required int fastPeriod,
    required int slowPeriod,
  }) async {
    try {
      final body = {
        'platform': 'mobile',
        'global': {
          'symbol': symbol,
          'timeframe': timeframe,
          'start_time': 1672531200,
          'end_time': 1704067200,
          'start_balance': 1000.0,
          'fee_percent': 0.1,
          'fast_period': fastPeriod,
          'slow_period': slowPeriod,
        },
        'strategy': {
          'name': 'RSI_Strategy',
          'parameters': {
            'rsi_period': 14,
            'buy_level': 30,
            'sell_level': 70,
          },
        },
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/backtest/run'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        return BacktestResult.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Ошибка запуска бэктеста');
    } on SocketException {
      throw Exception('Нет соединения с сервером');
    } on TimeoutException {
      throw Exception('Сервер долго не отвечает');
    } on FormatException {
      throw Exception('Некорректный ответ сервера');
    }
  }

  static Future<List<HistoryItem>> getHistory(
    String token, {
    int limit = 20,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/history'),
            headers: _headers,
            body: jsonEncode({
              'token': token,
              'limit': limit,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = _parseResponse(response);

      if (data['status'] == 'success') {
        final historyList = data['data'] as List<dynamic>? ?? [];

        return historyList
            .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception(data['message'] ?? 'Ошибка загрузки истории');
    } on SocketException {
      throw Exception('Нет соединения с сервером');
    } on TimeoutException {
      throw Exception('Сервер долго не отвечает');
    } on FormatException {
      throw Exception('Некорректный ответ сервера');
    } catch (e) {
      throw Exception('Parsing history error: $e');
    }
  }
  static Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Пустой ответ от сервера');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Неверный формат ответа сервера');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message'] ?? 'Ошибка сервера: ${response.statusCode}',
      );
    }

    return decoded;
  }
}
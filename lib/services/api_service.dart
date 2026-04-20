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
    } on FormatException {
      throw Exception('Некорректный ответ сервера');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<UserModel> register({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    return _handleRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'auth_data': {
                'email': email,
                'password': password,
                'user_name': name,
                'user_surname': surname,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _parseResponse(response);

      return UserModel.fromRegisterJson(
        data,
        name: name,
        surname: surname,
        email: email,
      );
    });
  }

  static Future<UserModel> login({
    required String email,
    required String password,
    String surname = '',
  }) async {
    return _handleRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _parseResponse(response);

      return UserModel.fromLoginJson(
        data,
        email: email,
        surname: surname,
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
    bool needChart = true,
  }) async {
    return _handleRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl/backtest'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'token': token,
              'need_chart': needChart,
              'settings': {
                'symbol': symbol,
                'timeframe': timeframe,
                'start_balance': startBalance,
                'fee_percent': feePercent,
              },
              'strategy': {
                'name': strategyName,
                'params': params,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _parseResponse(response);
      return BacktestResult.fromJson(data);
    });
  }

  static Future<List<HistoryItem>> getHistory(
    String token, {
    int limit = 10,
  }) async {
    return _handleRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl/history'),
            headers: _headers,
            body: jsonEncode({
              'platform': 'mobile',
              'token': token,
              'limit': limit,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = _parseResponse(response);
      final rawList = data['data'];

      if (rawList is! List) {
        throw Exception('Поле data не является списком');
      }

      return rawList
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Пустой ответ от сервера');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Неверный формат ответа сервера');
    }

    final data = decoded;

    if (data['status'] == 'error') {
      throw Exception(data['message']?.toString() ?? 'Ошибка сервера');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'Ошибка сервера: ${response.statusCode}',
      );
    }

    return data;
  }
}
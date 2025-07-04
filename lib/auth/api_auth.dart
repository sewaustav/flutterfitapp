import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class UserRegistration {

  Future<int> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$URL/accounts/api/register/'),
      body: {
        'username': username,
        'password': password,
        'email': email
      }
    );
    logger.i('Registration: ${response.statusCode}');
    return response.statusCode;
  }
  Future<int> getToken(String username, String password) async {
    final response = await http.post(
      Uri.parse('$URL/accounts/api/token/'),
      body: {
        'username': username,
        'password': password
      }
    );
    logger.i('Get Token: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final String accessToken = responseBody['access'];
      final String refreshToken = responseBody['refresh'];
      await _storage.write(key: 'access', value: accessToken);
      await _storage.write(key: 'refresh', value: refreshToken);

      return 1;
    }
    else {
      logger.i(response.statusCode);
      return 0;
    }
  }
}
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class RefreshToken {
  final _storage = FlutterSecureStorage();

  Future<void> getNewAccessToken() async {
    String? _RTOKEN = await _storage.read(key: 'refresh');
    try {
      logger.i(_RTOKEN);
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/accounts/api/token/refresh/'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'refresh': _RTOKEN
        }),
      );
      logger.i('TTT${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String _access = responseBody['access'];
        final String _refresh = responseBody['refresh'];
        _storage.write(key: 'access', value: _access);
        _storage.write(key: 'refresh', value: _refresh);
        logger.i(response.statusCode);
      }
      else {
        logger.i(response.body);
      }
    }
    catch (e) {
      logger.i(e);
    }
  }
}
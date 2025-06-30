import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutterfitapp/core/config.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class ApiExtraInfo {

  Future<void> postUserGoal(Map<String, dynamic> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.post(
        Uri.parse('$URL/accounts/api/user-goals/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data)
      );
      logger.i(response.statusCode);
      logger.i(response.body);
    }
    catch (e) {
      logger.i(e);
    }
  }

  Future<void> postExtraInfo(Map<String, dynamic> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');

      final getData = await http.get(
        Uri.parse('$URL/accounts/api/user-info/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Accept': 'application/json',
        },
      );
      final List userInfoList = jsonDecode(getData.body);
      final int userInfoId = userInfoList[0]['id'];
      final response = await http.put(
          Uri.parse('$URL/accounts/api/user-info/$userInfoId/'),
          headers: {
            'Authorization': 'Bearer $_TOKEN',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data)
      );
      logger.i('TRY${response.statusCode}');
    }
    catch (e) {
      logger.i(e);
    }
  }

  Future<void> completeGoal(int id) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      logger.i(id);
      final response = await http.patch(
        Uri.parse('$URL/accounts/api/user-goals/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_TOKEN'
        },
        body: jsonEncode({'status': true})
      );
      logger.i(response.statusCode);
    } catch (e) {
      logger.i(e);
    }
  }


}
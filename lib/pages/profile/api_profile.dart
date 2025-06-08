
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class ApiProfile {

  Future<List<dynamic>> getProfileInfo() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/accounts/api/profile/'),
          headers: {
            'Authorization': 'Bearer $_TOKEN',
            'Content-Type': 'application/json',
          }
      );
      if (response.statusCode == 200) {
        final List<dynamic> profileInfo = jsonDecode(utf8.decode(response.bodyBytes));
        return profileInfo;
      }
      else {
        logger.i(response.statusCode);
        return [];
      }
    }
    catch (e) {
      return [];
    }
  }

}

class Goals {
  
  Future<List<dynamic>> getGoals() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/accounts/api/user-goals/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        final List<dynamic> goalsList = jsonDecode(utf8.decode(response.bodyBytes));
        return goalsList;
      }
      else {
        logger.i(response.statusCode);
        return [];
      }
    }
    catch (e) {
      logger.i(e);
      return [];
    }
  }
  
  Future<void> updateGoals(Map<String, dynamic> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/accounts/api/user-goals/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data)
      );
      logger.i(response.statusCode);
    }
    catch (e) {
      logger.i(e);
    }
  }
  
  Future<void> deleteGoal(int id) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8888/accounts/api/user-goals/$id/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      logger.i(response.statusCode);
    }
    catch (e) {
      logger.i(e);
    }
  }
  
}

class GetInfo {

  Future<List<dynamic>> getExtraInfo() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/accounts/api/user-info/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        final List<dynamic> extraInfoList = jsonDecode(utf8.decode(response.bodyBytes));
        return extraInfoList;
      }
      else {
        logger.i(response.statusCode);
        return [];
      }
    }
    catch (e) {
      logger.i(e);
      return [];
    }
  }

  Future<void> updateInfo() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8888/accounts/api/user-info/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      logger.i(response.statusCode);
    }
    catch (e) {
      logger.i(e);
    }
  }

}
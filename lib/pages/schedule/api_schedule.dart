import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../core/config.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class GetMethods {

  Future<List<dynamic>> getSchedule() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('$URL/api/api/schedule/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      logger.i(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> scheduleList = json.decode(utf8.decode(response.bodyBytes));
        return scheduleList;
      }
      else {
        return [];
      }
    }
    catch (e) {
      logger.i(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> getNextPractice() async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
          Uri.parse('$URL/api/api/next_training'),
          headers: {
            'Authorization': 'Bearer $_TOKEN',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );
      logger.i('Next${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      else {
        return {};
      }
    }
    
    catch (e) {
      logger.i(e);
      return {};
    }
  }
  
  Future<List<dynamic>> getExercices(String programId) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('$URL/api/api/schedule_exercises/?workout=$programId'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        logger.i(response.statusCode);
        final List<dynamic> exerciseList = json.decode(utf8.decode(response.bodyBytes));
        return exerciseList;
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

}

class PostMethods {

  Future<int> postNextTraining(Map<String, dynamic> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.post(
        Uri.parse('$URL/api/api/schedule/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        logger.i(response.statusCode);
        final body = jsonDecode(response.body);
        final id = body['id'] as int;
        return id;
      }
      else {
        logger.i(response.statusCode);
        return -1;
      }

    }
    catch (e) {
      logger.i(e);
      return -1;
    }
  }

  Future<void> postNextTrainingSet(List<Map<String, dynamic>> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      for (final set in data) {
        final response = await http.post(
            Uri.parse('$URL/api/api/schedule_exercises/'),
            headers: {
              'Authorization': 'Bearer $_TOKEN',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(set)
        );

        logger.i(response.statusCode);
        logger.i(response.body);

      }
    }
    catch (e) {
      logger.i(e);
    }
  }

}

class DeleteMethods {

  Future<void> deleteFutureTraining(int id) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.delete(
          Uri.parse('$URL/schedule/$id/'),
          headers: {
            'Authorization': 'Bearer $_TOKEN'
          }
      );

      if (response.statusCode == 204) {
        logger.i('Response status:success: ${response.statusCode}');
      }
      else {logger.i('Response status: ${response.statusCode} ${response.body}');}
    }
    catch (e) {
      logger.i(e);
    }
  }
  
  Future<int> cleanSpace(int id) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.delete(
        Uri.parse('$URL/schedule_exercises/$id/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN'
        }
      );
      logger.i(response.statusCode);
      if (response.statusCode == 204) {
        return 1;
      }
      else {
        return 0;
      }
    }
    catch (e) {
      logger.i(e);
      return 0;
    };
  }

}


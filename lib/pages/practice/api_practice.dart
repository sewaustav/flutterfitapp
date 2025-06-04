import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class ApiService {

  // final String _TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUxMjk2Mjc1LCJpYXQiOjE3NDg3MDQyNzUsImp0aSI6Ijk2Y2M5ZjQzN2UxNDQzZGJiMDQ4NmI0OTA1OWU5MjdhIiwidXNlcl9pZCI6N30.2sS5DsdYRvHaitj4n6od6dBET7tvllQAYJbyYxYJ_io';
  final String _URL = 'http://127.0.0.1:8888/api/api/workout_result';

  Future<int> postTraining(Map<String, dynamic> data) async {
    String? _TOKEN = await _storage.read(key: 'access');
    try {
      final response = await http.post(
        Uri.parse('$_URL/'),
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

  Future<void> postTrainingSet(int workoutId, List<Map<String, dynamic>> data) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      for (final set in data) {
        final response = await http.post(
          Uri.parse('${_URL}_set/'),
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

class GetExercises {

  // final String _TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUxMjk2Mjc1LCJpYXQiOjE3NDg3MDQyNzUsImp0aSI6Ijk2Y2M5ZjQzN2UxNDQzZGJiMDQ4NmI0OTA1OWU5MjdhIiwidXNlcl9pZCI6N30.2sS5DsdYRvHaitj4n6od6dBET7tvllQAYJbyYxYJ_io';

  Future<List<dynamic>> getExercises(int programId) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      // logger.i('http://127.0.0.1:8888/api/api/program_exercise/?program=${programId}');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/api/api/program_exercise/?program=${programId}'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Accept': 'application/json',
        },
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
    catch (e){
      logger.i(e);
      return [];
    }
  }

}



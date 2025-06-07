import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();


class ApiServiceHistory {


  final String _URL = 'http://127.0.0.1:8888/api/api/workout_result';

  Future<List<dynamic>> getNameTraining(int user) async {
    String? _TOKEN = await _storage.read(key: 'access');
    try {
      final response = await http.get(
        Uri.parse('$_URL/?user=$user'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      logger.i(response.statusCode);
      if (response.statusCode == 200) {

        final List<dynamic> listOfPractices = json.decode(utf8.decode(response.bodyBytes));
        return listOfPractices;
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

  Future<List<dynamic>> getAllExercises(int practiceId) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      logger.i('${_URL}_set/?workout=$practiceId');
      final response = await http.get(
        Uri.parse('${_URL}_set/?workout=$practiceId'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      logger.i(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> listExercises = json.decode(utf8.decode(response.bodyBytes));
        logger.i(listExercises);
        return listExercises;
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

}
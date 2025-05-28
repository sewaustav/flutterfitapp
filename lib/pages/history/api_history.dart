import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

final logger = Logger();

class ApiServiceHistory {

  final String _TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String _URL = 'https://dotfit.pythonanywhere.com/api/api/workout_result';

  Future<List<dynamic>> getNameTraining(int user) async {
    try {
      final response = await http.get(
        Uri.parse('$_URL/?user=$user'),
        headers: {
          'Authorization': 'Token $_TOKEN',
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
      logger.i('${_URL}_set/?workout=$practiceId');
      final response = await http.get(
        Uri.parse('${_URL}_set/?workout=$practiceId'),
        headers: {
          'Authorization': 'Token $_TOKEN',
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
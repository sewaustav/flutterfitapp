import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class ApiService {

  final String _TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String _URL = 'https://dotfit.pythonanywhere.com/api/api/workout_result';

  Future<int> postTraining(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_URL/'),
        headers: {
          'Authorization': 'Token $_TOKEN',
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
      for (final set in data) {
        final response = await http.post(
          Uri.parse('${_URL}_set/'),
          headers: {
            'Authorization': 'Token $_TOKEN',
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

  final String _TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String _URL = 'https://dotfit.pythonanywhere.com/api/api/';

  Future<List<dynamic>> getExercises(int programId) async {
    try {
      final response = await http.get(
        Uri.parse('$_URL/program_exercise/?program=$programId'),
        headers: {
          'Authorization': 'Token $_TOKEN',
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



import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

final TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUxMjk2Mjc1LCJpYXQiOjE3NDg3MDQyNzUsImp0aSI6Ijk2Y2M5ZjQzN2UxNDQzZGJiMDQ4NmI0OTA1OWU5MjdhIiwidXNlcl9pZCI6N30.2sS5DsdYRvHaitj4n6od6dBET7tvllQAYJbyYxYJ_io';

class GetDataMethods {

  Future<List<dynamic>> getData(String programId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/api/api/program_exercise/?program=${int.parse(programId)}'),
        headers: {
          'Authorization': 'Token $TOKEN',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> exerciseList = jsonDecode(utf8.decode(response.bodyBytes));
        logger.i(exerciseList);
        return exerciseList;
      }
      else {
        return [response.statusCode];
      }
    }
    catch (e) {
      logger.i('fail');
      return [e];
    }
  }

  Future<List<dynamic>> getProgramList() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8888/api/api/dprogram'), headers: {
        'Authorization': 'Bearer $TOKEN',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(
            utf8.decode(response.bodyBytes));
        return jsonData;
      }
      else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getExcercises(String programId) async {
    try {
      logger.i('http://127.0.0.1:8888/api/api/program_exercise/program=${programId}');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/api/api/program_exercise/?program=${programId}'),
        headers: {
          'Authorization': 'Bearer $TOKEN',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> exerciseList = json.decode(utf8.decode(response.bodyBytes));
        logger.i(exerciseList);
        return exerciseList;
      }
      else {
        logger.i(response.statusCode);
        return [];
      }

    }
    catch (e) {
      logger.i('fail $e');
      return [];
    }
  }

}

class DeleteDataMethods {

  Future<void> deleteProgramExById(int id) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8888/api/api/program_exercise/$id/');
      logger.i(url);
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $TOKEN'}
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

  Future<void> deleteProgramByName(String name) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8888/api/api/programs/delete/$name');
      logger.i(url);
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $TOKEN'
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

}

class PostDataMethods {

  Future<void> submitWorkoutData(final workout) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/api/api/program_exercise/'),
        headers: {
          'Authorization': 'Bearer $TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(workout),
      );
      if (response.statusCode == 201) {
        logger.i('T${response.body}');
      }
      else {
        logger.i('HUI ${response.statusCode}');
      }
    }
    catch (e) {
      logger.i('$e');
    }
  }

  Future<int> createDprogram(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/api/api/dprogram/'),
        headers: {
          'Authorization': 'Bearer $TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        logger.i('Success ${response.statusCode}');
        final body = jsonDecode(response.body);
        logger.i(body);
        final id = body['id'] as int;
        logger.i('FFFF${body['id']}');
        return id;
      }
      else {
        logger.i('Fail ${response.statusCode} ${response.body}');
        return -1;
      }
    }
    catch (e){
      logger.i('$e');
      return -1;
    }
  }


}
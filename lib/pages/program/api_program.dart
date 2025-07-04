import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../core/config.dart';

final logger = Logger();

final _storage = FlutterSecureStorage();

class GetDataMethods {

  Future<List<dynamic>> getData(String programId) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('$URL/api/api/program_exercise/?program=${int.parse(programId)}'),
        headers: {
          'Authorization': 'Token $_TOKEN',
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
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(Uri.parse('$URL/api/api/dprogram'), headers: {
        'Authorization': 'Bearer $_TOKEN',
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
      String? _TOKEN = await _storage.read(key: 'access');
      logger.i('$URL/api/api/program_exercise/program=${programId}');
      final response = await http.get(
        Uri.parse('$URL/api/api/program_exercise/?program=${programId}'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
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
      String? _TOKEN = await _storage.read(key: 'access');
      final url = Uri.parse('$URL/api/api/program_exercise/$id/');
      logger.i(url);
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_TOKEN'}
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

  Future<void> deleteProgramByName(int id) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final url = Uri.parse('$URL/api/api/dprogram/$id/');
      logger.i(url);
      final response = await http.delete(
        url,
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

}

class PostDataMethods {

  Future<void> submitWorkoutData(final workout) async {
    try {
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.post(
        Uri.parse('$URL/api/api/program_exercise/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
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
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.post(
        Uri.parse('$URL/api/api/dprogram/'),
        headers: {
          'Authorization': 'Bearer $_TOKEN',
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
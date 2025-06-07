
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
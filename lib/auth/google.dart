import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'dart:html' as html;

import '../design/colors.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class AuthService extends StatefulWidget {
  const AuthService({super.key});

  @override
  State<AuthService> createState() => _AuthServiceState();
}

class _AuthServiceState extends State<AuthService> {

  Future<void> handleWebCallback() async {
    final uri = Uri.base;

    logger.i("FULL URI: $uri");
    final fragment = uri.fragment; // "/google-auth/?access_token=...&refresh_token=..."

    logger.i("Fragment: $fragment");

    // Извлекаем query-параметры из fragment, начиная с '?'
    final int queryStart = fragment.indexOf('?');
    if (queryStart != -1 && queryStart < fragment.length - 1) {
      final queryString = fragment.substring(queryStart + 1); // Без '?'
      final params = Uri.splitQueryString(queryString);

      final access = params['access_token'];
      final refresh = params['refresh_token'];

      if (access != null && refresh != null) {
        logger.i("Access token: $access");
        await _storage.write(key: 'access', value: access);
        await _storage.write(key: 'refresh', value: refresh);
      } else {
        logger.w("Tokens not found in fragment query.");
      }
    } else {
      logger.w("No query in fragment.");
    }
  }


  @override
  void initState() {
    super.initState();
    logger.i('message');
    handleWebCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Uri.base}', style: const TextStyle(
          color: Colors.white,
        )),
        backgroundColor: MyColors.blue_color,
      ),
      body: TextButton(onPressed: () {
        logger.i(Uri.base);
        context.go('/');
      },
      child: Text('${Uri.base}')),
    );
  }
}

import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uni_links/uni_links.dart';
import 'package:web/web.dart' as web;

final logger = Logger();

Future<void> handleIncomingAuthLink() async {
  Uri? uri;

  if (kIsWeb) {
    final href = web.window.location.href;
    uri = Uri.parse(href);
  } else {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        uri = Uri.parse(initialLink);
      }
    } on FormatException {
      logger.i('Невалидный deep link');
    }
  }

  if (uri == null) return;

  final token = uri.queryParameters['token'];
  if (token == null) {
    logger.i('Нет токена в ссылке');
    return;
  }
}

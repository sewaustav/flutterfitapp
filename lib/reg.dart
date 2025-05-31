import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  _GoogleSignInWebPageState createState() => _GoogleSignInWebPageState();
}

class _GoogleSignInWebPageState extends State<GoogleSignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '292291279413-viat1k1phegcjk1ipud0gga8e8nda39b.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );

  String _status = 'Не залогинен';

  @override
  void initState() {
    super.initState();
    logger.i('initState: Инициализация GoogleSignIn');

    _googleSignIn.onCurrentUserChanged.listen((account) async {
      logger.i('onCurrentUserChanged: аккаунт: $account');
      if (account != null) {
        logger.i('Получен аккаунт: email=${account.email}');
        try {
          final auth = await account.authentication;
          logger.i('auth.accessToken: ${auth.accessToken}');
          logger.i('auth.idToken: ${auth.idToken}');

          setState(() {
            _status = 'Вошли как ${account.email}, отправка токена...';
          });

          await _sendTokenToBackend(auth.idToken);
        } catch (e) {
          logger.e('Ошибка при получении auth: $e');
          setState(() {
            _status = 'Ошибка получения токена';
          });
        }
      } else {
        logger.w('Пользователь не залогинен');
        setState(() {
          _status = 'Не залогинен';
        });
      }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      logger.i('Начат процесс входа');
      await _googleSignIn.signIn();
      logger.i('Вход завершён успешно');
    } catch (error) {
      logger.e('Ошибка входа: $error');
      setState(() {
        _status = 'Ошибка входа: $error';
      });
    }
  }

  Future<void> _handleSignOut() async {
    logger.i('Процесс выхода начат');
    await _googleSignIn.signOut();
    logger.i('Выход выполнен');
    setState(() {
      _status = 'Вышли';
    });
  }

  Future<void> _sendTokenToBackend(String? idToken) async {
    if (idToken == null) {
      logger.w('idToken == null, отмена отправки');
      setState(() {
        _status = 'Не удалось получить idToken';
      });
      return;
    }

    logger.i('Отправка idToken на сервер: $idToken');

    try {
      final response = await http.post(
        Uri.parse('https://your-backend.com/api/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: '{"id_token": "$idToken"}',
      );

      logger.i('Ответ сервера: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Успешно авторизован через сервер!';
        });
      } else {
        setState(() {
          _status = 'Ошибка сервера: ${response.body}';
        });
      }
    } catch (e) {
      logger.e('Ошибка сети при отправке токена: $e');
      setState(() {
        _status = 'Ошибка сети: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In Web')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text('Войти'),
            ),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}

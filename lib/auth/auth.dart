import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../design/colors.dart';
import 'api_auth.dart';
import 'dart:html' as html;
import 'package:uuid/uuid.dart';

const uuid = Uuid();
String sessionId = uuid.v4();

final _storage = FlutterSecureStorage();

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  late UserRegistration userRegistration;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    userRegistration = UserRegistration();
    login();
  }

  Future<void> loginGoogle(String sessionId) async {
    try {
      final url = '$URL/accounts/api/google-auth/?session_id=$sessionId';  // адрес Django-авторизации
      html.window.open(url, 'GoogleAuth', 'width=500,height=600');
    } catch(e) {
      null;
    }
  }

  Future<void> authGoogle() async {
    const uuid = Uuid();
    String sessionId = uuid.v4();
    await loginGoogle(sessionId);
    await checkAuthStatus(sessionId);
  }


  Future<void> checkAuthStatus(String sessionId) async {
    final Uri url = Uri.parse('$URL/accounts/api/authstatus?session_id=$sessionId');

    Timer.periodic(Duration(seconds: 3), (Timer timer) async {
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];

          if (status == true) {
            logger.i("Статус TRUE — запускаем событие");

            final accessToken = data['access_token'];
            final refreshToken = data['refresh_token'];

            await _storage.write(key: 'access', value: accessToken);
            await _storage.write(key: 'refresh', value: refreshToken);

            timer.cancel();
            context.push('/');

          } else {
            logger.i("Статус FALSE — продолжаем опрос...");
          }
        } else {
          logger.i('Ошибка HTTP: ${response.statusCode}');
        }
      } catch (e) {
        logger.i('Ошибка при запросе: $e');
      }
    });
  }

  Future<void> login() async {
    try {
      final uri = Uri.base;

      if (uri.path == '/auth-google/') {
        final access = uri.queryParameters['access_token'];
        final refresh = uri.queryParameters['refresh_token'];

        if (access != null && refresh != null) {
          logger.i(access);
          await _storage.write(key: 'access', value: access);
          await _storage.write(key: 'refresh', value: refresh);
        }
      }
    } catch(e) {
      null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип или иконка
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: MyColors.blue_color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: MyColors.blue_color,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Заголовок
                    Text(
                      'Welcome to DotFit!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Форма
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Поле Username
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'username',
                                hintText: 'Enter username',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: MyColors.blue_color,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Поле Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: MyColors.blue_color,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to the registration page
                                    context.go('/sign-in'); // This will navigate to your sign-in/registration route
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: MyColors.blue_color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold, // Make it bold for emphasis
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Кнопка входа
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await userRegistration.getToken(
                                      _usernameController.text,
                                      _passwordController.text
                                  );
                                  context.go('/');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.blue_color,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: MyColors.blue_color.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {
                        authGoogle();
                        // context.go('/auth-google');
                      },
                      icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                      label: Text(
                        'Sign-in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),

                    // Дополнительные ссылки (опционально)
                    TextButton(
                      onPressed: () {
                        // Логика для "Забыли пароль?"
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: MyColors.blue_color,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
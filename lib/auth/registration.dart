import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';
import 'api_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  late UserRegistration userRegistration;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userRegistration = UserRegistration();
  }

  final _usernameInput = TextEditingController();
  final _password1 = TextEditingController();
  final _password2 = TextEditingController();
  final _emailInput = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameInput.dispose();
    _password1.dispose();
    _password2.dispose();
    _emailInput.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),

                  // Заголовок
                  Text(
                    'Create profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Fill fields for sign in',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40),

                  // Поле username
                  TextFormField(
                    controller: _usernameInput,
                    decoration: InputDecoration(
                      hintText: 'username',
                      prefixIcon: Icon(Icons.person_outline, color: MyColors.blue_color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your username';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Поле email
                  TextFormField(
                    controller: _emailInput,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: MyColors.blue_color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Поле password
                  TextFormField(
                    controller: _password1,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: MyColors.blue_color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Поле повтор пароля
                  TextFormField(
                    controller: _password2,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Repeat password',
                      prefixIcon: Icon(Icons.lock_outline, color: MyColors.blue_color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: MyColors.blue_color, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Repeat password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 32),

                  // Кнопка регистрации
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_password1.text == _password2.text) {
                            final statusCode = await userRegistration.register(
                                _usernameInput.text,
                                _password1.text,
                                _emailInput.text
                            );
                            if (statusCode == 201) {
                              final token = await userRegistration.getToken(
                                  _usernameInput.text,
                                  _password1.text
                              );
                              logger.i(token);
                            }
                          }
                          context.push('/add-info', extra: 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.blue_color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                  ),

                  SizedBox(height: 16),

                  // Кнопка регистрации через Google
                  OutlinedButton.icon(
                    onPressed: () {
                      // Пустое действие для регистрации через Google
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

                  SizedBox(height: 24),

                  // Разделитель
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Кнопка перехода на страницу входа
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: MyColors.blue_color,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),
                ],
              ),
            )
        )
    );
  }

}
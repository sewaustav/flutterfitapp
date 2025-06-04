import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameInput,
            decoration: InputDecoration(hintText: 'username'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Enter username';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _password1,
            decoration: InputDecoration(hintText: 'password'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Enter password';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _password2,
            decoration: InputDecoration(hintText: 'password again'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Enter password';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailInput,
            decoration: InputDecoration(hintText: 'email'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Enter email';
              }
              return null;
            },
          ),
          TextButton(
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
                  context.go('/');
                }
              },
              child: Text('Registrate')
          )
        ],
      )
    );
  }

}
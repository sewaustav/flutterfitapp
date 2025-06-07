import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'api_auth.dart';

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
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
            ),
            TextButton(
                onPressed: () async {
                  await userRegistration.getToken(
                    _usernameController.text,
                    _passwordController.text
                  );
                  context.go('/');
                },
                child: Text('Enter'))
          ],
        ),
      )
    );
  }

}
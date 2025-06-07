import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/auth/extra_info/api_info.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class AddExtraInfo extends StatefulWidget {
  const AddExtraInfo({super.key});

  @override
  State<AddExtraInfo> createState() => _AddExtraInfoState();

}

class _AddExtraInfoState extends State<AddExtraInfo> {

  final logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ApiExtraInfo apiExtraInfo;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _weightController.dispose();
    _heightController.dispose();
  }

  @override
  void initState() {
    super.initState();
    apiExtraInfo = ApiExtraInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _heightController,
              
            ),
            TextFormField(
              controller: _weightController,
            ),
            TextButton(onPressed: () {
              apiExtraInfo.postExtraInfo({'weight': _weightController.text, 'height': _heightController.text
              });
              context.push('/add-goal');
              }, child: Text('Submit'))
          ],
        )
      ),
    );
  }

}
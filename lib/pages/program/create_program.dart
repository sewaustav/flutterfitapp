import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class CreateProgramPage extends StatefulWidget {
  const CreateProgramPage({super.key});

  @override
  State<CreateProgramPage> createState() => _CreateProgramPageState();
}

class _CreateProgramPageState extends State<CreateProgramPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Create', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
      body: FormExercise(),
    );
  }

}

class FormExercise extends StatefulWidget {
  const FormExercise({super.key});

  @override
  State<FormExercise> createState() => _FormExerciseState();
}

class _FormExerciseState extends State<FormExercise> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String token = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String baseUrl = 'https://dotfit.pythonanywhere.com/api/api/dprogram/';


  Future<int> createDprogram(Map<String, dynamic> data) async {
    try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'Authorization': 'Token $token',  // <-- Добавьте заголовок
            'Content-Type': 'application/json',  // Рекомендуется для JSON
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          logger.i('Success ${response.statusCode}');
          final body = jsonDecode(response.body);
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

  final _nameProgram = TextEditingController();
  final _typeProgram = TextEditingController();

  @override
  void dispose() {
    _nameProgram.dispose();
    _typeProgram.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _nameProgram,
            decoration: const InputDecoration(hintText: "Name of program"),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _typeProgram,
            decoration: const InputDecoration(hintText: "Type"),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {

                    final programId = await createDprogram({
                      'name': _nameProgram.text,
                      'user': 3,
                      'description': 'Best program',
                      'type_of_program': _typeProgram.text,
                    });

                    if (mounted) {
                      context.push('/create_training', extra: programId);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }

              },
              child: const Text('Submit'),
            ),
          ),
        ],
      )
    );
  }
}

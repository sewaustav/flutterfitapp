import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'api_program.dart';

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
  late PostDataMethods postDataMethods;

  final _nameProgram = TextEditingController();
  final _typeProgram = TextEditingController();

  @override
  void initState() {
    super.initState();
    postDataMethods = PostDataMethods();
  }

  @override
  void dispose() {
    super.dispose();
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

                    final programId = await postDataMethods.createDprogram({
                      'name': _nameProgram.text,
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

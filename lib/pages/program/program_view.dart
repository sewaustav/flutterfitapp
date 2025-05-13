import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/home_page.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../program_app/exercise_model.dart';

final logger = Logger();

class ProgramViewPage extends StatefulWidget {
  const ProgramViewPage({super.key, required this.programId});

  final String programId;

  @override
  State<ProgramViewPage> createState() => _ProgramViewPageState();
}

class _ProgramViewPageState extends State<ProgramViewPage> {

  List<dynamic> exercises = [];
  late Box<Exercise> exerciseBox;

  final String TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';

  Future<void> _getExcercises() async {
    try {
      logger.i(widget.programId);
      logger.i('https://dotfit.pythonanywhere.com/api/api/program_exercise/program=${widget.programId}');
      final response = await http.get(
          Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/?program=${widget.programId}'),
          headers: {
            'Authorization': 'Token $TOKEN',
            'Content-Type': 'application/json',
          },
      );
      if (response.statusCode == 200) {
        final List<dynamic> exerciseList = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          exercises = exerciseList;
          logger.i(exercises);
        });
      }
      else {
        logger.i(response.statusCode);
      }

    }
    catch (e) {
      logger.i('fail $e');
    }
  }

  String getExerciseName(int? exerciseId) {
    if (exerciseId == null) return 'Неизвестное упражнение';

    final exercise = exerciseBox.values.firstWhere(
          (e) => e.id == exerciseId,
      orElse: () => Exercise(name: 'Неизвестное упражнение', muscleGroup: '', id: null),
    );

    return exercise.name;
  }

  @override
  void initState() {
    super.initState();
    _getExcercises();
    exerciseBox = Hive.box<Exercise>('exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: const Text('Fitapp',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final exerciseId = exercise['exercise'] as int?;

          return ListTile(
            title: Text(getExerciseName(exerciseId)),

          );
        },
      ),
    );
  }

}
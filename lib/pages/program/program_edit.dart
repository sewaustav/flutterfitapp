import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../program_app/exercise_model.dart';

final logger = Logger();

class ProgramEditPage extends StatefulWidget {
  const ProgramEditPage({super.key, required this.programId});

  final String programId;

  @override
  State<ProgramEditPage> createState() => _ProgramEditPageState();
}

class _ProgramEditPageState extends State<ProgramEditPage> {

  List<dynamic> exercises = [];
  late Box<Exercise> exerciseBox;
  List<Exercise> allExercises = [];

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
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
    _get_data();
    logger.i(exercises);
  }

  final List<Map<String, dynamic>> _workoutFields = [
    {'exercise': '', 'sets': '', 'reps': '', 'weight': ''}
  ];

  List<Exercise?> _selectedExercises = [null];

  final List<TextEditingController> _setsControllers = [TextEditingController()];
  final List<TextEditingController> _repsControllers = [TextEditingController()];
  final List<TextEditingController> _weightControllers = [TextEditingController()];

  void _initForm() {
    setState(() {
      _workoutFields.clear();
      _setsControllers.clear();
      _repsControllers.clear();
      _weightControllers.clear();
      _selectedExercises.clear();

      for (final ex in exercises) {
        final exerciseId = ex['exercise'];
        final exercise = allExercises.firstWhere(
              (e) => e.id == exerciseId,
          orElse: () => Exercise(name: 'Unknown', muscleGroup: '', id: null),
        );

        _workoutFields.add({
          'exercise': exerciseId,
          'sets': ex['sets'].toString(),
          'reps': ex['reps'].toString(),
          'weight': ex['weight'].toString(),
        });

        _selectedExercises.add(exercise);
        _setsControllers.add(TextEditingController(text: ex['sets'].toString()));
        _repsControllers.add(TextEditingController(text: ex['reps'].toString()));
        _weightControllers.add(TextEditingController(text: ex['weight'].toString()));

      }
    });
  }

  void _addWorkoutField() {
    setState(() {
      _workoutFields.add({'exercise': '', 'sets': '', 'reps': '', 'weight': ''});
      _selectedExercises.add(null);
      _setsControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
      _weightControllers.add(TextEditingController());
    });
  }

  void _deleteWorkoutField(int index) {
    if (_workoutFields.length > 1) {
      setState(() {
        _workoutFields.removeAt(index);
        _setsControllers.removeAt(index);
        _repsControllers.removeAt(index);
        _weightControllers.removeAt(index);
      });
    }
  }

  final String TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  
  Future<void> _get_data() async {
    try {
      final response = await http.get(
        Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/?program=${widget.programId}'),
        headers: {
          'Authorization': 'Token $TOKEN',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> exerciseList = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          exercises = exerciseList;
          logger.i(exercises);
          _initForm();
        });
      }
    }
    catch (e) {
      logger.i('fail');
    }
  }

  Future<void> _deleteProgramExById(int id) async {
    try {
      final url = Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/$id/');
      logger.i(url);
      final response = await http.delete(url, headers: {'Authorization': 'Token $TOKEN'});

      if (response.statusCode == 204) {
        logger.i('Response status:success: ${response.statusCode}');
      }
      else {logger.i('Response status: ${response.statusCode} ${response.body}');}
    }
    catch (e) {
      logger.i(e);
    }
  }

  Future<void> _editDataTest() async {
    List<Map<String, dynamic>> workoutData = [];
    logger.i('TTT${_workoutFields.length}');
    for (int i = 0; i < _workoutFields.length; i++) {
      workoutData.add({
        'program': widget.programId,
        'exercise': _selectedExercises[i]?.id,
        'sets': _setsControllers[i].text,
        'reps': _repsControllers[i].text,
        'weight': _weightControllers[i].text,
      });
    }

    try {
      for (int i = 0; i < exercises.length; i++) {
        await _deleteProgramExById(exercises[i]['id']);
      }
    }
    catch (e) {
      logger.i(e);
    }
    try {
      for (final workout in workoutData) {
        logger.i(workout);
        final response = await http.post(
            Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/'),
            headers: {
              'Authorization': 'Token $TOKEN',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(workout)
        );
        if (response.statusCode == 200) {
          logger.i('to ${response.body}');
        }
        else {
          logger.i('HUI ${response.statusCode}');
        }
      }
      context.go('/programs');
    }
    catch (e) {
      logger.i('$e');
    }

  }

  Future<void> _editProgram() async {
    List<Map<String, dynamic>> workoutData = [];
    logger.i('TTT${_workoutFields.length}');
    for (int i = 0; i < _workoutFields.length; i++) {
      workoutData.add({
        'program': widget.programId,
         'exercise': _selectedExercises[i]?.id,
        'sets': _setsControllers[i].text,
        'reps': _repsControllers[i].text,
        'weight': _weightControllers[i].text,
      });
    }
    int index = 0;
    try {
      for (final workout in workoutData) {
        final response = await http.put(
          Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/${exercises[index]['id']}/'),
          headers: {
            'Authorization': 'Token $TOKEN',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(workout)
        );
        logger.i('${exercises[index]['id']}');
        logger.i('${workout['exercise']}');
        index++;
        if (response.statusCode == 200) {
          logger.i('to ${response.body}');
        }
        else {
          logger.i(response.statusCode);
        }
      }
      context.go('/programs');
    }
    catch (e) {
      logger.i('$e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitapp', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _workoutFields.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [

                          DropdownButtonFormField<Exercise>(
                            decoration: InputDecoration(labelText: 'Exercise'),
                            value: _selectedExercises[index],
                            items: allExercises.map((exercise) {
                              return DropdownMenuItem<Exercise>(
                                value: exercise,
                                child: Text(exercise.name),
                              );
                            }).toList(),
                            onChanged: (Exercise? newValue) {
                              setState(() {
                                _selectedExercises[index] = newValue;
                                _workoutFields[index]['exercise'] = newValue?.id;
                              });
                            },
                          ),

                          TextField(
                            controller: _setsControllers[index],
                            decoration: InputDecoration(labelText: 'Sets'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _workoutFields[index]['sets'] = value;
                            },
                          ),
                          TextField(
                            controller: _repsControllers[index],
                            decoration: InputDecoration(labelText: 'Reps'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _workoutFields[index]['reps'] = value;
                            },
                          ),
                          TextField(
                            controller: _weightControllers[index],
                            decoration: InputDecoration(labelText: 'weight (kg)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _workoutFields[index]['weight'] = value;
                            },
                          ),
                          if (_workoutFields.length > 1)
                            TextButton(
                              onPressed: () => _deleteWorkoutField(index),
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addWorkoutField,
              child: Text('Add exercise'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editDataTest,
              child: Text('Save program', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'api_program.dart';

import '../program_app/exercise_model.dart';

final logger = Logger();

class ProgramEditPage extends StatefulWidget {
  const ProgramEditPage({super.key, required this.programId});

  final String programId;

  @override
  State<ProgramEditPage> createState() => _ProgramEditPageState();
}

class _ProgramEditPageState extends State<ProgramEditPage> {

  late PostDataMethods postDataMethods;
  late GetDataMethods getDataMethods;
  late DeleteDataMethods deleteDataMethods;

  List<dynamic> exercises = [];
  late Box<Exercise> exerciseBox;
  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    _init();
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
  }

  Future<void> _init() async {
    getDataMethods = GetDataMethods();
    postDataMethods = PostDataMethods();
    deleteDataMethods = DeleteDataMethods();
    logger.i(widget.programId);
    final list = await getDataMethods.getExcercises(widget.programId);
    setState(() {
      exercises = list;
      _initForm();
    });
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
        logger.i(ex);
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
      logger.i(index);
      setState(() {
        _workoutFields.removeAt(index);
        _selectedExercises.removeAt(index);
        _setsControllers.removeAt(index);
        _repsControllers.removeAt(index);
        _weightControllers.removeAt(index);
        logger.i(_workoutFields);
      });
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
        await deleteDataMethods.deleteProgramExById(exercises[i]['id']);
      }
    }
    catch (e) {
      logger.i(e);
    }
    try {
      for (final workout in workoutData) {
        postDataMethods.submitWorkoutData(workout);
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
              onPressed: () => _editDataTest(),
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
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../program_app/exercise_model.dart';
import 'api_program.dart';

final logger = Logger();

class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key, required this.programId});
  final String programId;
  
  @override
  State<AddExercisesPage> createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {

  late Box<Exercise> exerciseBox;
  late PostDataMethods postDataMethods;

  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
    postDataMethods = PostDataMethods();
  }


  final List<Map<String, dynamic>> _workoutFields = [
    {'exercise': '', 'sets': '', 'reps': '', 'weight': ''}
  ];

  List<Exercise?> _selectedExercises = [null];
  final List<TextEditingController> _setsControllers = [TextEditingController()];
  final List<TextEditingController> _repsControllers = [TextEditingController()];
  final List<TextEditingController> _weightControllers = [TextEditingController()];

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
        _selectedExercises.removeAt(index);
        _setsControllers.removeAt(index);
        _repsControllers.removeAt(index);
        _weightControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitWorkoutData() async {
    List<Map<String, dynamic>> workoutData = [];
    for (int i = 0; i < _workoutFields.length; i++) {
      workoutData.add({
        'program': widget.programId,
        'exercise': _setsControllers[i].text,
        'sets': _setsControllers[i].text,
        'reps': _repsControllers[i].text,
        'weight': _weightControllers[i].text,
      });
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
          padding: const EdgeInsets.all(16.0),
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
              onPressed: _submitWorkoutData,
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
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'api_schedule.dart';

import '../program_app/exercise_model.dart';

final logger = Logger();

class FuturePracticeEditPage extends StatefulWidget {
  const FuturePracticeEditPage({super.key, required this.programId});

  final String programId;

  @override
  State<FuturePracticeEditPage> createState() => _FuturePracticeEditPageState();
}

class _FuturePracticeEditPageState extends State<FuturePracticeEditPage> with TickerProviderStateMixin {

  late PutMethod putMethod;
  late GetMethods getMethods;
  late AnimationController _animationController;

  List<dynamic> exercises = [];
  late Box<Exercise> exerciseBox;
  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    _init();
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _setsControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    getMethods = GetMethods();
    putMethod = PutMethod();
    logger.i(widget.programId);
    final list = await getMethods.getExercices(widget.programId);
    setState(() {
      exercises = list;
      _initForm();
    });
  }

  final List<Map<String, dynamic>> _workoutFields = [
    {'exercise': '', 'sets': '', 'reps': ''}
  ];

  List<Exercise?> _selectedExercises = [null];

  final List<TextEditingController> _setsControllers = [TextEditingController()];
  final List<TextEditingController> _repsControllers = [TextEditingController()];

  void _initForm() {
    setState(() {
      _workoutFields.clear();
      _setsControllers.clear();
      _repsControllers.clear();
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
          'id': ex['id'], // Store the ID for PUT requests
        });

        _selectedExercises.add(exercise);
        _setsControllers.add(TextEditingController(text: ex['sets'].toString()));
        _repsControllers.add(TextEditingController(text: ex['reps'].toString()));
      }
    });
  }

  void _addWorkoutField() {
    setState(() {
      _workoutFields.add({'exercise': '', 'sets': '', 'reps': '', 'id': null}); // New entries have no ID
      _selectedExercises.add(null);
      _setsControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
    });
    _animationController.forward();
  }

  void _deleteWorkoutField(int index) {
    if (_workoutFields.length > 1) {
      logger.i(index);
      setState(() {
        _workoutFields.removeAt(index);
        _selectedExercises.removeAt(index);
        _setsControllers[index].dispose();
        _repsControllers[index].dispose();
        _setsControllers.removeAt(index);
        _repsControllers.removeAt(index);
        logger.i(_workoutFields);
      });
    }
  }

  Future<void> _updateProgram() async {
    try {
      for (int i = 0; i < _workoutFields.length; i++) {
        final workoutData = {
          'program': widget.programId,
          'exercise': _selectedExercises[i]?.id,
          'sets': int.tryParse(_setsControllers[i].text) ?? 0,
          'reps': int.tryParse(_repsControllers[i].text) ?? 0,
        };

        final exerciseId = _workoutFields[i]['id'];

        if (exerciseId != null) {
          // Update existing exercise
          await putMethod.updateProgramExById(exerciseId, workoutData);
          logger.i('Updated exercise with ID: $exerciseId');
        } else {
          // For new exercises, you might need a POST method
          // This depends on your API structure
          logger.i('New exercise needs to be created: $workoutData');
        }
      }

      // Navigate to schedule page on success
      if (mounted) {
        context.go('/schedule');
      }
    } catch (e) {
      logger.e('Error updating program: $e');
      // You might want to show an error dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitness App', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColors.blue_color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Program',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Modify your workout program',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _workoutFields.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with exercise number and delete button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: MyColors.blue_color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Exercise ${index + 1}',
                                          style: TextStyle(
                                            color: MyColors.blue_color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (_workoutFields.length > 1)
                                        GestureDetector(
                                          onTap: () => _deleteWorkoutField(index),
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Exercise dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: DropdownButtonFormField<Exercise>(
                                      decoration: InputDecoration(
                                        labelText: 'Select Exercise',
                                        prefixIcon: Icon(Icons.fitness_center, color: MyColors.blue_color),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                      ),
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
                                  ),

                                  SizedBox(height: 16),

                                  // Input fields row (removed weight field)
                                  Row(
                                    children: [
                                      // Sets field
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: TextField(
                                            controller: _setsControllers[index],
                                            decoration: InputDecoration(
                                              labelText: 'Sets',
                                              prefixIcon: Icon(Icons.repeat, color: Colors.orange, size: 20),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              labelStyle: TextStyle(color: Colors.grey[600]),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              _workoutFields[index]['sets'] = value;
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),

                                      // Reps field
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: TextField(
                                            controller: _repsControllers[index],
                                            decoration: InputDecoration(
                                              labelText: 'Reps',
                                              prefixIcon: Icon(Icons.refresh, color: Colors.green, size: 20),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              labelStyle: TextStyle(color: Colors.grey[600]),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              _workoutFields[index]['reps'] = value;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom buttons
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Add exercise button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addWorkoutField,
                            icon: Icon(Icons.add, color: MyColors.blue_color),
                            label: Text(
                              'Add Exercise',
                              style: TextStyle(
                                color: MyColors.blue_color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: MyColors.blue_color,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: MyColors.blue_color, width: 2),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Update program button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _updateProgram(),
                            icon: Icon(Icons.update, color: Colors.white),
                            label: Text(
                              'Update Program',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.green.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
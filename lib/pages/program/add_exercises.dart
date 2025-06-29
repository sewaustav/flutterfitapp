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

class _AddExercisesPageState extends State<AddExercisesPage> with TickerProviderStateMixin {

  late Box<Exercise> exerciseBox;
  late PostDataMethods postDataMethods;
  late AnimationController _animationController;

  List<Exercise> allExercises = [];

  @override
  void initState() {
    super.initState();
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
    postDataMethods = PostDataMethods();
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
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
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
    _animationController.forward();
  }

  void _deleteWorkoutField(int index) {
    if (_workoutFields.length > 1) {
      setState(() {
        _workoutFields.removeAt(index);
        _selectedExercises.removeAt(index);
        _setsControllers[index].dispose();
        _repsControllers[index].dispose();
        _weightControllers[index].dispose();
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
        'exercise': _selectedExercises[i]?.id,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitapp', style:
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
                  'Добавить упражнения',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Создайте свою программу тренировок',
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
                                          'Упражнение ${index + 1}',
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
                                        labelText: 'Выберите упражнение',
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

                                  // Input fields row
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
                                              labelText: 'Подходы',
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
                                              labelText: 'Повторы',
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
                                      SizedBox(width: 12),

                                      // Weight field
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: TextField(
                                            controller: _weightControllers[index],
                                            decoration: InputDecoration(
                                              labelText: 'Вес (кг)',
                                              prefixIcon: Icon(Icons.monitor_weight, color: Colors.purple, size: 20),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              labelStyle: TextStyle(color: Colors.grey[600]),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              _workoutFields[index]['weight'] = value;
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
                              'Добавить упражнение',
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

                        // Save program button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitWorkoutData,
                            icon: Icon(Icons.save, color: Colors.white),
                            label: Text(
                              'Save program',
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
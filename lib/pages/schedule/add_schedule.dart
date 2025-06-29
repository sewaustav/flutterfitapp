import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../program_app/exercise_model.dart';
import 'api_schedule.dart';

final logger = Logger();

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> with TickerProviderStateMixin {

  late Box<Exercise> exerciseBox;
  late PostMethods postMethods;
  late AnimationController _animationController;

  List<Exercise> allExercises = [];

  // Workout info controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    exerciseBox = Hive.box<Exercise>('exercises');
    allExercises = exerciseBox.values.toList();
    postMethods = PostMethods();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    for (var controller in _setsControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  final List<Map<String, dynamic>> _workoutFields = [
    {'exercise': '', 'sets': '', 'reps': ''}
  ];

  List<Exercise?> _selectedExercises = [null];
  final List<TextEditingController> _setsControllers = [TextEditingController()];
  final List<TextEditingController> _repsControllers = [TextEditingController()];

  void _addWorkoutField() {
    setState(() {
      _workoutFields.add({'exercise': '', 'sets': '', 'reps': ''});
      _selectedExercises.add(null);
      _setsControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
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
        _setsControllers.removeAt(index);
        _repsControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MyColors.blue_color,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _createWorkout() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter workout name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create workout data
    Map<String, dynamic> workoutData = {
      'name': _nameController.text.trim(),
      'date': _selectedDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'notes': _notesController.text.trim(),
    };

    try {
      // First create the schedule entry
      final workoutId = await postMethods.postNextTraining(workoutData);

      if (workoutId != -1) {
        // Then create exercise sets
        List<Map<String, dynamic>> exerciseData = [];
        for (int i = 0; i < _workoutFields.length; i++) {
          if (_selectedExercises[i] != null &&
              _setsControllers[i].text.isNotEmpty &&
              _repsControllers[i].text.isNotEmpty) {
            exerciseData.add({
              'workout': workoutId,
              'exercise': _selectedExercises[i]!.id,
              'sets': _setsControllers[i].text,
              'reps': _repsControllers[i].text,
            });
          }
        }

        if (exerciseData.isNotEmpty) {
          await postMethods.postNextTrainingSet(exerciseData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        context.replace('/schedule');
      } else {
        throw Exception('Failed to create workout');
      }
    } catch (e) {
      logger.e('Error creating workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create workout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text(
          'Create Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/schedule'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0), // Уменьшили отступы
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
                    'Create New Workout',
                    style: TextStyle(
                      fontSize: 24, // Уменьшили размер шрифта
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4), // Уменьшили отступ
                  Text(
                    'Schedule your training session',
                    style: TextStyle(
                      fontSize: 14, // Уменьшили размер шрифта
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Workout info form
                  Container(
                    margin: EdgeInsets.only(bottom: 12), // Уменьшили отступ
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
                      padding: const EdgeInsets.all(16.0), // Уменьшили отступы
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: MyColors.blue_color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Workout Details',
                              style: TextStyle(
                                color: MyColors.blue_color,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          SizedBox(height: 16), // Уменьшили отступ

                          // Name field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Workout Name *',
                                prefixIcon: Icon(Icons.fitness_center, color: MyColors.blue_color),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),

                          SizedBox(height: 12), // Уменьшили отступ

                          // Date field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: MyColors.blue_color),
                                    SizedBox(width: 12),
                                    Text(
                                      'Date: ${_formatDate(_selectedDate)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12), // Уменьшили отступ

                          // Notes field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 2, // Уменьшили количество строк
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                prefixIcon: Icon(Icons.note_outlined, color: Colors.grey[600]),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Exercises list
                  ListView.builder(
                    shrinkWrap: true, // Важно для использования внутри Column
                    physics: NeverScrollableScrollPhysics(), // Отключаем прокрутку для ListView
                    itemCount: _workoutFields.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(bottom: 12), // Уменьшили отступ
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
                            padding: const EdgeInsets.all(16.0), // Уменьшили отступы
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

                                SizedBox(height: 16), // Уменьшили отступ

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

                                SizedBox(height: 12), // Уменьшили отступ

                                // Input fields row (only sets and reps)
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
                                    SizedBox(width: 16),

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
                                            labelText: 'Recommended Reps',
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

                  // Bottom buttons
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
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
                              padding: EdgeInsets.symmetric(vertical: 14), // Уменьшили отступы
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: MyColors.blue_color, width: 2),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Create workout button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createWorkout,
                            icon: Icon(Icons.schedule, color: Colors.white),
                            label: Text(
                              'Create Workout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 16), // Уменьшили отступы
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
          ],
        ),
      ),
    );
  }
}
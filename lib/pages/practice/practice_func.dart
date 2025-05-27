import 'package:flutter/cupertino.dart';
import 'package:flutterfitapp/home_page.dart';
import 'package:hive/hive.dart';
import '../program_app/exercise_model.dart';
import 'package:flutter/material.dart';

abstract class IExerciseRepository {
  Future<void> loadExercises();
  String getExerciseName(int? exerciseId);
  List<Exercise> get allExercises;
}

abstract class IWorkoutFormManager {
  List<Map<String, dynamic>> get workoutFields;
  List<Exercise?> get exercises;
  List<List<TextEditingController>> get repsControllers;
  List<List<TextEditingController>> get weightControllers;
  Map<int, Map<int, bool>> get checkedStates;


  void clearAllFields();
  void fillData(List<dynamic> data, String programId);
  void addExercise(int exercise, int set);
  void deleteWorkoutField(int index);
  void addSet(int exercise, int set);
  List<Map<String, dynamic>> getWorkoutData(String programId);
  void dispose();
}

class TitleFormManager {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final notes = TextEditingController();

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
  }
}

class ExerciseRepository implements IExerciseRepository {
  late Box<Exercise> _exerciseBox;
  final List<Exercise> _allExercises = [];

  @override
  Future<void> loadExercises() async {
    _exerciseBox = await Hive.openBox<Exercise>('exercises');
    _allExercises.clear();
    _allExercises.addAll(_exerciseBox.values.toList());
  }

  @override
  String getExerciseName(int? exerciseId) {
    final exercise = _allExercises.firstWhere(
          (e) => e.id == exerciseId,
      orElse: () => Exercise(name: 'Неизвестное упражнение', muscleGroup: '', id: null),
    );
    return exercise.name;
  }

  @override
  List<Exercise> get allExercises => List.unmodifiable(_allExercises);
}

class WorkoutFormManager implements IWorkoutFormManager {
  @override
  final List<Map<String, dynamic>> workoutFields = [];
  @override
  List<Exercise?> exercises = [];
  @override
  final List<List<TextEditingController>> repsControllers = [];
  @override
  final List<List<TextEditingController>> weightControllers = [];
  @override
  final Map<int, Map<int, bool>> checkedStates = {};


  @override
  void addExercise(int exercise, int set) {

    exercises.add(null);
    List<TextEditingController> repsForExercise = [];
    List<TextEditingController> weightsForExercise = [];
    for (int i = 0; i < set; i++) {
      workoutFields.add({'exercise': exercise, 'set': i+1, 'weight': ''});
      repsForExercise.add(TextEditingController(text: ''));
      weightsForExercise.add(TextEditingController(text: ''));
    }
    repsControllers.add(repsForExercise);
    weightControllers.add(weightsForExercise);

  }

  @override
  void addSet(int exercise, int set) {
    workoutFields.add({'exercise': '', 'workout': '', 'set': '', 'reps': '', 'weight': ''});

  }

  @override
  void deleteWorkoutField(int index) {
    if (workoutFields.length > 1) {
      workoutFields.removeAt(index);
      exercises.removeAt(index);
      repsControllers.removeAt(index);
      weightControllers.removeAt(index);
    }
  }

  @override
  void clearAllFields() {
    dispose();
    workoutFields.clear();
    exercises.clear();
  }

  @override
  List<Map<String, dynamic>> getWorkoutData(String programId) {
    List<Map<String, dynamic>> workoutData = [];

    for (int i = 0; i < exercises.length; i++) {
      final exerciseId = exercises[i]?.id;
      if (exerciseId == null) continue;

      for (int j = 0; j < repsControllers[i].length; j++) {
        workoutData.add({
          'workout': programId,
          'exercise': exerciseId,
          'reps': repsControllers[i][j].text,
          'weight': weightControllers[i][j].text,
        });
      }
    }

    return workoutData;
  }

  @override
  void fillData(List<dynamic> data, String programId) {
    logger.i(data);

    for (final element in data) {
      logger.i(element['sets']);
      int setCount = element['sets'];
      List<TextEditingController> repsForExercise = [];
      List<TextEditingController> weightsForExercise = [];
      for (int i = 0; i < setCount; i++) {
        // repsForExercise.add(TextEditingController(text: element['reps'].toString()));
        // weightsForExercise.add(TextEditingController(text: element['weight'].toString()));
        repsForExercise.add(TextEditingController(text: ''));
        weightsForExercise.add(TextEditingController(text: ''));
        workoutFields.add({
          'exercise': element['exercise'],
          'set': i+1,
          'rep': element['reps'],
          'weight': element['weight']
        });
      }
      repsControllers.add(repsForExercise);
      weightControllers.add(weightsForExercise);
    }

  }


  @override
  void dispose() {
    for (final repsList in repsControllers) {
      for (final controller in repsList) {
        controller.dispose();
      }
    }

    for (final weightList in weightControllers) {
      for (final controller in weightList) {
        controller.dispose();
      }
    }

    repsControllers.clear();
    weightControllers.clear();
  }



}



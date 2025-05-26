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

    void clearAllFields();
    void fillData(List<dynamic> data, String programId);
    void addWorkoutField();
    void deleteWorkoutField(int index);
    List<Map<String, dynamic>> getWorkoutData(String programId);
    void dispose();
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
    void addWorkoutField() {
      workoutFields.add({'exercise': '', 'workout': '', 'set': '', 'reps': '', 'weight': ''});
      exercises.add(null);
      repsControllers.add([TextEditingController()]);
      weightControllers.add([TextEditingController()]);
    }

    @override
    void deleteWorkoutField(int index) {
      if (workoutFields.length > 0) {
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
      addWorkoutField();
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

      for (int i = 0; i < data.length; i++) {
        int setCount = data[i]['sets'];
        String reps = data[i]['reps'].toString();
        String weight = data[i]['weight'].toString();
        int? exerciseId = data[i]['exercise'];

        Exercise? exercise = ExerciseRepository().allExercises.firstWhere(
              (e) => e.id == exerciseId,
          orElse: () => Exercise(name: 'Неизвестное', muscleGroup: '', id: null),
        );

        exercises.add(exercise);
        workoutFields.add({
          'exercise': exercise?.name ?? '',
          'workout': programId,
          'set': setCount.toString(),
          'reps': reps,
          'weight': weight,
        });

        List<TextEditingController> repsList = [];
        List<TextEditingController> weightList = [];

        for (int i = 0; i < setCount; i++) {
          repsList.add(TextEditingController(text: reps));
          weightList.add(TextEditingController(text: weight));
        }

        repsControllers.add(repsList);
        weightControllers.add(weightList);
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



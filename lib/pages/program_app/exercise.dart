import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'dart:convert';
import 'package:flutterfitapp/pages/program_app/list_exercise.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'exercise_model.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Exercise> exercises = [];
  bool isLoading = true;
  late Box<Exercise> exerciseBox;

  final String token = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String baseUrl = 'http://127.0.0.1:8000/api/api/exercise/';

  @override
  void initState() {
    super.initState();
    _initHive().then((_) => fetchExercises());
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    exerciseBox = await Hive.openBox<Exercise>('exercises');
    _loadLocalExercises();
  }

  void _loadLocalExercises() {
    setState(() {
      exercises = exerciseBox.values.toList();
      isLoading = false;
    });
  }

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        await _updateLocalStorage(jsonData);
        _loadLocalExercises();
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateLocalStorage(List<dynamic> newExercises) async {
    // Clear old data
    await exerciseBox.clear();

    // Add new data
    for (var exercise in newExercises) {
      final ex = Exercise.fromJson(exercise);
      await exerciseBox.add(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: const Text('Упражнения', style:
          TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
          ? const Center(child: Text('Нет данных о упражнениях'))
          : ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            title: Text(exercise.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Основная группа: ${exercise.muscleGroup}'),
                if (exercise.secondGroup != null)
                  Text('Доп. группа: ${exercise.secondGroup}'),
                if (exercise.rating != null)
                  Text('Рейтинг: ${exercise.rating}'),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }
}
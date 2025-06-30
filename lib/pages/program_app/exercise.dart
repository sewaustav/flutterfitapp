import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/config.dart';
import '../../design/images.dart';
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

  final String baseUrl = '$URL/api/api/exercise/';
  final _storage = FlutterSecureStorage();

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
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Bearer $_TOKEN',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
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
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: dumbell,
            title: Text(
              exercise.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.emoji_people, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Основная группа: ${exercise.muscleGroup}'),
                  ],
                ),
                if (exercise.secondGroup != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Доп. группа: ${exercise.secondGroup}'),
                    ],
                  ),
                ],
                if (exercise.rating != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Рейтинг: ${exercise.rating}'),
                    ],
                  ),
                ],
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
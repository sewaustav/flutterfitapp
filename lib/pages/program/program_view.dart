import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/home_page.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../program_app/exercise_model.dart';

final logger = Logger();

class ProgramViewPage extends StatefulWidget {
  const ProgramViewPage({super.key, required this.programId});

  final String programId;

  @override
  State<ProgramViewPage> createState() => _ProgramViewPageState();
}

class _ProgramViewPageState extends State<ProgramViewPage> {

  List<dynamic> exercises = [];
  late Box<Exercise> exerciseBox;

  final String TOKEN = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';

  Future<void> _getExcercises() async {
    try {
      logger.i(widget.programId);
      logger.i('https://dotfit.pythonanywhere.com/api/api/program_exercise/program=${widget.programId}');
      final response = await http.get(
          Uri.parse('https://dotfit.pythonanywhere.com/api/api/program_exercise/?program=${widget.programId}'),
          headers: {
            'Authorization': 'Token $TOKEN',
            'Content-Type': 'application/json',
          },
      );
      if (response.statusCode == 200) {
        final List<dynamic> exerciseList = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          exercises = exerciseList;
          logger.i(exercises);
        });
      }
      else {
        logger.i(response.statusCode);
      }

    }
    catch (e) {
      logger.i('fail $e');
    }
  }

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
    _getExcercises();
    exerciseBox = Hive.box<Exercise>('exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: const Text(
          'Программа',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final exerciseId = exercise['exercise'] as int?;

          return _ExerciseCard(
            title: getExerciseName(exerciseId),
            sets: exercise['sets']?.toString() ?? '3',
            reps: exercise['reps']?.toString() ?? '8-12',
            weight: exercise['weight']?.toString() ?? '—',
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String sets;
  final String reps;
  final String weight;

  const _ExerciseCard({
    required this.title,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricBadge(icon: Icons.repeat, value: '$sets подх.'),
                  _MetricBadge(icon: Icons.timer, value: '$reps повт.'),
                  _MetricBadge(icon: Icons.monitor_weight, value: '$weight кг'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetricBadge({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MyColors.blue_color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: MyColors.blue_color),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
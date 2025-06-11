import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';

import 'api_program.dart';
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
  late GetDataMethods getDataMethods;

  String getExerciseName(int? exerciseId) {
    if (exerciseId == null) return 'Unknown Exercise';

    final exercise = exerciseBox.values.firstWhere(
          (e) => e.id == exerciseId,
      orElse: () => Exercise(name: 'Unknown Exercise', muscleGroup: '', id: null),
    );

    return exercise.name;
  }

  @override
  void initState() {
    super.initState();
    _init();
    exerciseBox = Hive.box<Exercise>('exercises');
  }

  Future<void> _init() async {
    getDataMethods = GetDataMethods();
    final response = await getDataMethods.getExcercises(widget.programId);
    setState(() {
      exercises = response;
    });
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
      body: Column(
        children: [
          // Edit Program Button at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/edit_training', extra: int.parse(widget.programId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.blue_color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'Edit Program',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Exercises List
          Expanded(
            child: exercises.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No exercises yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final exerciseId = exercise['exercise'] as int?;

                return _ExerciseCard(
                  title: getExerciseName(exerciseId),
                  sets: exercise['sets']?.toString() ?? '3',
                  reps: exercise['reps']?.toString() ?? '8-12',
                  exerciseNumber: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String sets;
  final String reps;
  final int exerciseNumber;

  const _ExerciseCard({
    required this.title,
    required this.sets,
    required this.reps,
    required this.exerciseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with exercise number and title
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: MyColors.blue_color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$exerciseNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Metrics
                Row(
                  children: [
                    Expanded(
                      child: _MetricContainer(
                        icon: Icons.repeat,
                        label: 'SETS',
                        value: sets,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricContainer(
                        icon: Icons.fitness_center,
                        label: 'REPS',
                        value: reps,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricContainer extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricContainer({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
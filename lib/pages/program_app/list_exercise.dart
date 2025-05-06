import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'exercise_model.dart';
import 'package:flutterfitapp/design/images.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  late Box<Exercise> exerciseBox; // open hive

  @override
  void initState() {
    super.initState();
    exerciseBox = Hive.box<Exercise>('exercises');
  }

  @override
  Widget build(BuildContext context) {
    final exercises = exerciseBox.values.toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Список упражнений', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
      body: exercises.isEmpty
          ? const Center(child: Text('Нет истории упражнений'))
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

}
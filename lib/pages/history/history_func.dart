import 'package:hive/hive.dart';
import '../program_app/exercise_model.dart';

abstract class IExerciseRepository {
  Future<void> loadExercises();
  String getExerciseName(int? exerciseId);
  List<Exercise> get allExercises;
}

class ExerciseRepository extends IExerciseRepository {
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
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'api_history.dart';
import 'history_func.dart';


class WorkoutDetailPage extends StatefulWidget {
  const WorkoutDetailPage({super.key, required this.programId});
  final String programId;



  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  late final ApiServiceHistory _apiService;
  late final IExerciseRepository _exerciseRepository;
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiServiceHistory();
    _exerciseRepository = ExerciseRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Загружаем список упражнений
      await _exerciseRepository.loadExercises();

      // Получаем данные о подходах из API
      final exercisesData = await _apiService.getAllExercises(int.parse(widget.programId));

      // Группируем подходы по упражнениям
      final groupedExercises = _groupExercises(exercisesData);

      setState(() {
        _exercises = groupedExercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _groupExercises(List<dynamic> exercisesData) {
    final Map<String, dynamic> grouped = {};

    for (var exercise in exercisesData) {
      final exerciseId = exercise['exercise'].toString();
      if (!grouped.containsKey(exerciseId)) {
        grouped[exerciseId] = {
          'exercise_id': exercise['exercise'],
          'exercise_name': _exerciseRepository.getExerciseName(exercise['exercise']),
          'sets': [],
        };
      }
      grouped[exerciseId]['sets'].add({
        'set': exercise['set'],
        'reps': exercise['rep'],
        'weight': exercise['weight'],
      });
    }

    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: const Text(
          'Детали тренировки',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(MyColors.blue_color),
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      )
          : _exercises.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No workout data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a workout to see your history here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColors.blue_color.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColors.blue_color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: MyColors.blue_color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_exercises.length} exercises completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_exercises.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildExerciseCard(_exercises[index], index + 1),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int exerciseNumber) {
    final sets = exercise['sets'] as List<dynamic>;
    final totalSets = sets.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Exercise Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColors.blue_color.withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: MyColors.blue_color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$exerciseNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['exercise_name'] ?? 'Exercise',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalSets ${totalSets == 1 ? 'set' : 'sets'} completed',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.fitness_center,
                  color: MyColors.blue_color.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),

          // Sets Table
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Reps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Weight (kg)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Table Rows
                ...sets.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  final isLastRow = index == sets.length - 1;

                  return Container(
                    margin: EdgeInsets.only(bottom: isLastRow ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: MyColors.blue_color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              set['set'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: MyColors.blue_color,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set['reps'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set['weight']?.toString() ?? '-',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: set['weight'] != null ? Colors.black87 : Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
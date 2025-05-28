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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _exercises.isEmpty
          ? const Center(
        child: Text(
          'Нет данных о выполненных упражнениях',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          return _buildExerciseCard(_exercises[index]);
        },
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['exercise_name'] ?? 'Упражнение',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildSetsTable(exercise['sets']),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSetsTable(List<dynamic> sets) {
    return [
      const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Подход',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Повторения',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Вес (кг)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      const Divider(height: 16, thickness: 1),
      ...sets.map<Widget>((set) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(set['set'].toString()),
              ),
              Expanded(
                flex: 2,
                child: Text(set['reps'].toString()),
              ),
              Expanded(
                flex: 2,
                child: Text(set['weight']?.toString() ?? '-'),
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }
}
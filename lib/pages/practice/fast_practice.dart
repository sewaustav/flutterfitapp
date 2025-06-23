import '../../design/colors.dart';
import 'practice_func.dart';
import 'api_practice.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'practice_dialog_widget.dart';
import 'dart:async';

class FastPracticePage extends StatefulWidget {
  const FastPracticePage({super.key});

  @override
  State<FastPracticePage> createState() => _FastPracticePageState();
}

class _FastPracticePageState extends State<FastPracticePage> {
  late final ApiService apiService;
  late final GetExercises getExercises;
  late final IExerciseRepository exerciseRepo;
  late final IWorkoutFormManager formManager;
  late final TitleFormManager titleFormManager;

  List<dynamic> programData = [];

  // Переменные для фич
  bool _isHeaderVisible = true;
  final DateTime _workoutStartTime = DateTime.now(); // Сделали final и убрали late
  double _totalTonnage = 0.0;

  // Создаем GlobalKey для доступа к таймеру
  final GlobalKey<_WorkoutTimerState> _timerKey = GlobalKey<_WorkoutTimerState>();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    titleFormManager = TitleFormManager();
    getExercises = GetExercises();
    apiService = ApiService();
    exerciseRepo = ExerciseRepository();
    formManager = WorkoutFormManager();

    await exerciseRepo.loadExercises();
  }

  void _calculateTotalTonnage() {
    double tonnage = 0.0;
    for (var field in formManager.workoutFields) {
      try {
        double weight = double.tryParse(field['weight'] ?? '0') ?? 0.0;
        int reps = int.tryParse(field['rep'] ?? '0') ?? 0;
        tonnage += weight * reps;
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }
    setState(() {
      _totalTonnage = tonnage;
    });
  }

  Future<void> _showRestTimer() async {
    showDialog(
      context: context,
      builder: (context) => RestTimerDialog(),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finish Workout?'),
        content: Text('Are you sure you want to finish the workout? All unsaved data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Finish'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showSaveConfirmation() async {
    final currentDuration = _timerKey.currentState?.currentDuration ?? Duration.zero;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Workout?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workout time: ${_formatDuration(currentDuration)}'),
            Text('Total tonnage: ${_totalTonnage.toStringAsFixed(1)} kg'),
            SizedBox(height: 10),
            Text('Save this workout?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Save'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  int getGlobalIndex(int exerciseIndex, int setIndex) {
    int globalIndex = 0;
    for (int i = 0; i < exerciseIndex; i++) {
      globalIndex += programData[i]['sets'] as int;
    }
    return globalIndex + setIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await _showExitConfirmation();
        if (shouldExit) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.blue_color,
          title: Text('Fitapp', style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          )),
          actions: [
            IconButton(
              icon: Icon(Icons.timer, color: Colors.white),
              onPressed: _showRestTimer,
            ),
          ],
        ),
        body: Column(
          children: [
            // Виджет таймера тренировки (теперь отдельный)
            WorkoutTimer(
              key: _timerKey,
              startTime: _workoutStartTime,
              totalTonnage: _totalTonnage,
              isHeaderVisible: _isHeaderVisible,
              onToggleHeader: () {
                setState(() {
                  _isHeaderVisible = !_isHeaderVisible;
                });
              },
            ),

            // Формы заголовка и заметок (скрываемые)
            if (_isHeaderVisible)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleFormManager.title,
                      decoration: const InputDecoration(
                        labelText: 'Session Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleFormManager.notes,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: programData.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  exerciseRepo.getExerciseName(programData[index]['exercise']),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    int idEx = programData[index]['exercise'];
                                    formManager.workoutFields.removeWhere((field) => field['exercise'] == idEx);
                                    programData.removeAt(index);
                                    _calculateTotalTonnage();
                                    logger.i(formManager.workoutFields);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: programData[index]['sets'],
                            itemBuilder: (context, setIndex) {
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  setState(() {
                                    int globalIndex = getGlobalIndex(index, setIndex);
                                    formManager.workoutFields.removeAt(globalIndex);
                                    formManager.repsControllers[index].removeAt(setIndex);
                                    formManager.weightControllers[index].removeAt(setIndex);

                                    formManager.checkedStates[index]?.remove(setIndex);

                                    programData[index]['sets'] = (programData[index]['sets'] as int) - 1;

                                    if (programData[index]['sets'] == 0) {
                                      programData.removeAt(index);
                                      formManager.repsControllers.removeAt(index);
                                      formManager.weightControllers.removeAt(index);
                                      formManager.checkedStates.remove(index);
                                    }
                                    _calculateTotalTonnage();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text('${setIndex + 1}'),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: TextFormField(
                                            controller: formManager.weightControllers[index][setIndex],
                                            onChanged: (value) {
                                              formManager.workoutFields[getGlobalIndex(index, setIndex)]['weight'] = value;

                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'Weight',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: TextFormField(
                                            controller: formManager.repsControllers[index][setIndex],
                                            onChanged: (value) {
                                              formManager.workoutFields[getGlobalIndex(index, setIndex)]['rep'] = value;

                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'Reps',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: formManager.checkedStates[index]?[setIndex] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _calculateTotalTonnage();
                                            formManager.checkedStates[index] ??= {};
                                            formManager.checkedStates[index]![setIndex] = value ?? false;
                                            logger.i(formManager.workoutFields);
                                          });
                                        },
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                        fillColor: WidgetStateProperty.resolveWith<Color>(
                                              (Set<WidgetState> states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.green;
                                            }
                                            return Colors.white;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add set'),
                              onPressed: () {
                                setState(() {
                                  programData[index]['sets'] = (programData[index]['sets'] as int) + 1;
                                  formManager.addSet(index, programData[index]['exercise']);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => AddExerciseDialog(exerciseRepo: exerciseRepo),
                  );

                  if (result != null) {
                    logger.i(result);
                    setState(() {
                      programData.add({
                        'exercise': result['exercise'],
                        'sets': result['sets']
                      });
                      formManager.addExercise(result['exercise'], result['sets']);
                    });
                  }
                },
                icon: Icon(Icons.fitness_center, size: 20),
                label: Text('Add Exercise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[500]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    _calculateTotalTonnage();
                    final shouldSave = await _showSaveConfirmation();

                    if (shouldSave) {
                      final currentDuration = _timerKey.currentState?.currentDuration ?? Duration.zero;
                      logger.i(currentDuration);

                      final tr_id = await apiService.postTraining({
                        'name': titleFormManager.title.text,
                        'notes': titleFormManager.notes.text,
                        'duration': currentDuration.inSeconds,
                        'tonnage': _totalTonnage,
                      });

                      if (tr_id != -1) {
                        List<Map<String, dynamic>> data = [];
                        for (int i = 0; i < formManager.workoutFields.length; i++) {
                          data.add({
                            'workout': tr_id,
                            'exercise': formManager.workoutFields[i]['exercise'],
                            'set': formManager.workoutFields[i]['set'],
                            'rep': int.parse(formManager.workoutFields[i]['rep']),
                            'weight': int.parse(formManager.workoutFields[i]['weight'])
                          });
                        }
                        logger.i(data);
                        apiService.postTrainingSet(tr_id, data);
                        context.go('/history');
                      } else {
                        logger.i('Error');
                      }
                    }
                  },
                  icon: Icon(Icons.save, size: 24),
                  label: Text('End Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Отдельный виджет для таймера тренировки
class WorkoutTimer extends StatefulWidget {
  final DateTime startTime;
  final double totalTonnage;
  final VoidCallback onToggleHeader;
  final bool isHeaderVisible;

  const WorkoutTimer({
    Key? key,
    required this.startTime,
    required this.totalTonnage,
    required this.onToggleHeader,
    required this.isHeaderVisible,
  }) : super(key: key);

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(widget.startTime);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Геттер для доступа к текущей длительности
  Duration get currentDuration => _duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Time', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(_formatDuration(_duration),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              Text('Tonnage', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('${widget.totalTonnage.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: Icon(widget.isHeaderVisible ? Icons.expand_less : Icons.expand_more),
            onPressed: widget.onToggleHeader,
          ),
        ],
      ),
    );
  }
}

// Диалог таймера отдыха (без изменений)
class RestTimerDialog extends StatefulWidget {
  @override
  _RestTimerDialogState createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  final List<int> _presetTimes = [30, 60, 90, 120, 180, 300];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _stopTimer();
          _showTimeUpDialog();
        }
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time is up!'),
        content: Text('Rest time is over. Ready for the next set?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rest Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_seconds),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Select time or set your own:'),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _presetTimes.map((time) {
              return ElevatedButton(
                onPressed: _isRunning ? null : () {
                  setState(() {
                    _seconds = time;
                  });
                },
                child: Text('${time}s'),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _isRunning ? null : () {
                  setState(() {
                    _seconds = (_seconds + 30).clamp(0, 999);
                  });
                },
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: _isRunning ? null : () {
                  setState(() {
                    _seconds = (_seconds - 30).clamp(0, 999);
                  });
                },
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _resetTimer,
          child: Text('Reset'),
        ),
        TextButton(
          onPressed: _seconds > 0 ? (_isRunning ? _stopTimer : _startTimer) : null,
          child: Text(_isRunning ? 'Pause' : 'Start'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
import '../../design/colors.dart';
import 'practice_func.dart';
import 'api_practice.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'practice_dialog_widget.dart';


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

  int getGlobalIndex(int exerciseIndex, int setIndex) {
    int globalIndex = 0;
    for (int i = 0; i < exerciseIndex; i++) {
      globalIndex += programData[i]['sets'] as int;
    }
    return globalIndex + setIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitapp', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
      body: Column(
        children: [
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
                                          onChanged: (value) {formManager.workoutFields[getGlobalIndex(index, setIndex)]['weight'] = value;},
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
                                          onChanged: (value) {formManager.workoutFields[getGlobalIndex(index, setIndex)]['rep'] = value;},
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
                                          formManager.checkedStates[index] ??= {};
                                          formManager.checkedStates[index]![setIndex] = value ?? false;
                                          logger.i(formManager.workoutFields);
                                          // logger.i('$index  $setIndex');
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
          ElevatedButton(
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
            child: Text('Add exercise'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final tr_id = await apiService.postTraining({
                  'name': titleFormManager.title.text,
                  'notes': titleFormManager.notes.text
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
                }
                else {
                  logger.i('Error');
                }
                context.go('/history');
              },
              child: const Text('End Session'),
            ),
          ),
        ],
      ),
    );
  }

}
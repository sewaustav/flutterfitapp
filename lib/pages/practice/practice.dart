import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import '../program_app/exercise_model.dart';
import 'api_practice.dart';
import 'practice_func.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.programId});
  final String programId;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {

  late final ApiService apiService;
  late final GetExercises getExercises;
  late final IExerciseRepository exerciseRepo;
  late final IWorkoutFormManager formManager;

  List<dynamic> programData = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    getExercises = GetExercises();
    apiService = ApiService();
    exerciseRepo = ExerciseRepository();
    formManager = WorkoutFormManager();

    await exerciseRepo.loadExercises();
    await loadExercises();
  }

  Future<void> loadExercises() async {
    programData = await getExercises.getExercises(int.parse(widget.programId));
    logger.i(programData);
    formManager.fillData(programData, widget.programId);
    setState(() {
      programData = programData;
    });
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
                                formManager.deleteWorkoutField(index);
                                setState(() {

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
                              key: Key('set_${index}_$setIndex'),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {

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
                                          // controller: formManager.weightControllers[index][setIndex],
                                          onChanged: (value) {formManager.workoutFields[index]['reps'] = value;},
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
                                          onChanged: (value) {formManager.workoutFields[index]['reps'] = value;},
                                          decoration: const InputDecoration(
                                            labelText: 'Reps',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: false,
                                      onChanged: (bool? value) {

                                      },
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
          ElevatedButton(onPressed: (){}, child: Text('Add exercise')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {

              },
              child: const Text('End Session'),
            ),
          ),
        ],
      ),
    );
  }

}


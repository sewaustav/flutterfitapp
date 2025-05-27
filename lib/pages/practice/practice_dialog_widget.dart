import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/pages/practice/practice_func.dart';

class AddExerciseDialog extends StatefulWidget {
  final IExerciseRepository exerciseRepo;

  const AddExerciseDialog({required this.exerciseRepo, super.key});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  int? selectedExerciseId;
  int sets = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: selectedExerciseId,
            decoration: InputDecoration(labelText: 'Exercise'),
            items: widget.exerciseRepo.allExercises.map((exercise) {
              return DropdownMenuItem<int>(
                value: exercise.id,
                child: Text(exercise.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedExerciseId = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: '1',
            decoration: InputDecoration(labelText: 'Sets'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              sets = int.tryParse(value) ?? 1;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedExerciseId == null
              ? null
              : () {
            Navigator.pop(context, {
              'exercise': selectedExerciseId,
              'sets': sets,
              'reps': 0,
              'weight': 0,
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
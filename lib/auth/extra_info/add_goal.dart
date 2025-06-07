import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/auth/extra_info/api_info.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();

}

class _AddGoalPageState extends State<AddGoalPage> {

  late ApiExtraInfo apiExtraInfo;
  final logger = Logger();

  final List<Map<String, dynamic>> _goalList = [
    {'goal': '', 'final_day_of_goal': ''}
  ];

  final List<TextEditingController> _goalNameController = [TextEditingController()];
  final List<TextEditingController> _dateController = [TextEditingController()];

  void _addGoal() {
    setState(() {
      _goalList.add({'goal': '', 'final_day_of_goal': ''});
      _goalNameController.add(TextEditingController());
      _dateController.add(TextEditingController());
    });
  }

  void _deleteGoal(int index) {
    if (_goalList.isNotEmpty) {
      setState(() {
        _goalList.removeAt(index);
        _goalNameController.removeAt(index);
        _dateController.removeAt(index);
      });
    }
  }

  Future<void> _submitData() async {
    List<Map<String, dynamic>> goalData = [];
    for (int i = 0; i < _goalList.length; i++) {
      goalData.add({
        'goal': _goalNameController[i].text,
        'final_day_of_goal': _dateController[i].text
      });
    }
    try {
      for (final goal in goalData) {
        await apiExtraInfo.postUserGoal(goal);
      }
      context.go('/');
    }
    catch (e) {
      logger.i(e);
    }
  }

  @override
  void initState() {
    super.initState();
    apiExtraInfo = ApiExtraInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить цель'),
      ),
      body: ListView.builder(
        itemCount: _goalList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _goalNameController[index],
                    decoration: InputDecoration(labelText: 'Цель'),
                  ),
                  TextFormField(
                    controller: _dateController[index],
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Дата'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _dateController[index].text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_goalList.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteGoal(index),
                        ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _submitData,
          child: Text('Сохранить'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }


}
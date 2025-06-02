import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'api_program.dart';

final logger = Logger();


class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  List<dynamic> programs = [];
  late GetDataMethods getDataMethods;
  late DeleteDataMethods deleteDataMethods;


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    getDataMethods = GetDataMethods();
    deleteDataMethods = DeleteDataMethods();

    final programList = await getDataMethods.getProgramList();
    setState(() {
      programs = programList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text(
          'Programs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),

      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                          onPressed: () => context.go('/create'),
                          child: Text("Create Training"))
                    ],
                  )
                ],
              ),
              
              Column(
                children: programs.map((program) {
                  return Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(16),
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: MyColors.blue_color, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
  
                    child: Align(
                      alignment: Alignment.topCenter,
  
                      child: Column(
                        children: [
  
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
  
                            Expanded(child:
                                InkWell(
                                  child: Text(program['name'] ?? 'None', style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 30,
                                  ),),
                                  onTap: () {
                                    context.push('/view_training', extra: program['id']);
                                  },
                                  hoverColor: Colors.transparent,
                                )

                            ),
  
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert), // Иконка "три точки"
                              itemBuilder: (context) => [
                                PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                                PopupMenuItem(value: 'delete', child: Text('Удалить')),
                              ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  context.push('/edit_training', extra: program['id']);
                                } else if (value == 'delete') {
                                  await deleteDataMethods.deleteProgramByName(program['name']);
                                  final programList = await getDataMethods.getProgramList();
                                  setState(() {
                                    programs = programList;
                                  });
                                }
                              },
                            )
                          ]),
  
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(program['description'] ?? 'Without description'),
                          ),

  
                          Container(
                            margin: EdgeInsets.only(top: 50),
                            child: SizedBox(width: 200,child:
                              TextButton(
                                  onPressed: () => context.push('/practice', extra: program['id']),
                                  style: TextButton.styleFrom(
                                    backgroundColor: MyColors.blue_color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  ),
                                  child: Text('Start session', style: TextStyle(
                                    color: Colors.white,
                                  ),)
                              )),
                          ),
                        ],
                      ),
                    )
                  );
                }).toList(),
            ),
        ]),
      ),
    ));
  }
}
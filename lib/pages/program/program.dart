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
      backgroundColor: Colors.grey[50],
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Секция с кнопкой создания
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColors.blue_color.withOpacity(0.1),
                    MyColors.blue_color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MyColors.blue_color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MyColors.blue_color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: MyColors.blue_color,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create a new program',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add a personal program',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.blue_color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Заголовок списка программ
            if (programs.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  'Your programs (${programs.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],

            // Список программ
            if (programs.isEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'There are no programs yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first program',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: programs.map((program) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 400,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Градиентный фон
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MyColors.blue_color.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Заголовок и меню
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          context.push('/view_training', extra: program['id']);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 4),
                                          child: Text(
                                            program['name'] ?? 'None',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 22,
                                              color: Colors.grey[800],
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        offset: Offset(0, 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                                                SizedBox(width: 12),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                                                SizedBox(width: 12),
                                                Text('Delete', style: TextStyle(color: Colors.red[400])),
                                              ],
                                            ),
                                          ),
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
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Описание
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    program['description'] ?? 'Description is empty',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Кнопка запуска
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/practice', extra: program['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColors.blue_color,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_arrow, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Start session',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
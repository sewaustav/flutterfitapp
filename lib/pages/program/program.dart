import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();


class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  List<dynamic> programs = [];
  bool isLoading = true;
  final String token = '7eb2178a8b4c92c149cd1ea79ef02fd4240edb92';
  final String baseUrl = 'http://127.0.0.1:8000/api/api/dprogram';

  Future<void> getListProgram() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(
            utf8.decode(response.bodyBytes));
        setState(() {
          programs = jsonData;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteProgramByName(String name, ) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/api/programs/delete/$name');
      logger.i(url);
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 204) {
        logger.i('Response status:success: ${response.statusCode}');
      }
      else {logger.i('Response status: ${response.statusCode}');}
    }
    catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    getListProgram();
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
                          Text(program['name'] ?? 'None', style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),),
                        ),

                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert), // Иконка "три точки"
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                            PopupMenuItem(value: 'delete', child: Text('Удалить')),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              print('Редактировать');
                            } else if (value == 'delete') {
                              deleteProgramByName(program['name']);
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
                              onPressed: null,
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
        ),),
    );
  }
}
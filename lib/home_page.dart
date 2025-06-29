import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:flutterfitapp/auth/token_script.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/pages/profile/api_profile.dart';
import 'package:flutterfitapp/pages/program_app/exercise_model.dart';
import 'package:flutterfitapp/design/images.dart';
import 'package:flutterfitapp/pages/schedule/api_schedule.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


final logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Exercise> exercises = [];
  Map<String, dynamic> nextTrainingInfo = {};

  int countPractices = 0;

  late Box<Exercise> exerciseBox;
  late RefreshToken refreshToken;
  late Practices practices;
  late GetMethods getMethods;

  Future<void> _getKeys() async {
    bool containsKeyAccess= await _storage.containsKey(key: 'accept');
    bool containsKeyRefresh = await _storage.containsKey(key: 'refresh');
    if (!containsKeyRefresh) {
      context.go('/login');
    }
    else {
      final bool isValid = await checkValidToken();
      if (isValid) {
        await refreshToken.getNewAccessToken();
      }
      else {
        context.go('/login');
      }
    }
  }

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initHive().then((_) => fetchExercises());
    refreshToken = RefreshToken();
    practices = Practices();
    getMethods = GetMethods();
    _getKeys();
    loadData();
  }

  Future<void> loadData() async {
    int getterCountPractises = await practices.getNumberPractices();
    Map<String, dynamic> info = await getMethods.getNextPractice();
    setState(() {
      countPractices = getterCountPractises;
      nextTrainingInfo = info;
    });
  }

  Future<bool> checkValidToken() async {
    String? access = await _storage.read(key: 'access');
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/accounts/api/profile/'),
        headers: {
          'Authorization': 'Bearer $access'
        }
    );
    return response.statusCode == 200;
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    exerciseBox = await Hive.openBox<Exercise>('exercises');
  }

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8888/api/api/exercise/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        await _updateLocalStorage(jsonData);
      }
      logger.i(response.statusCode);
    } catch (e) {
      logger.i(e);
    }
  }

  Future<void> _updateLocalStorage(List<dynamic> newExercises) async {
    await exerciseBox.clear();
    for (var exercise in newExercises) {
      final ex = Exercise.fromJson(exercise);
      await exerciseBox.add(ex);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style:TextStyle(
          color: Colors.white,
        )),
        backgroundColor: MyColors.blue_color,
      ),

      body: Stack(
        children: [
          Image.asset(
            'assets/images/main.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            fit: BoxFit.cover,
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              return true;
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 32),
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  Container(
                    padding: EdgeInsets.only(top: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Welcome to the DotFit!",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),

                          StartTrainButton(),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              "Your Smart Workout Companion — Track your progress, get personalized AI-powered practice plans, and reach your fitness goals faster.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 16),

                          // Next Workout Schedule Section - new feature in progress
                          NextWorkoutSection(nextTrainingInfo: nextTrainingInfo),

                          // Quick Stats Section
                          QuickStatsSection(practicesCount: countPractices),

                          // Quick Actions Section
                          QuickActionsSection(),

                          // Tools & Calculators Section
                          ToolsSection(),

                          SizedBox(height: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 32),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Navigation(),
    );
  }
}

class StartTrainButton extends StatelessWidget {
  const StartTrainButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
            width: 150,
            child: Column(
                children: [
                  TextButton(
                      onPressed: () => context.go('/fast_practice'),
                      style: TextButton.styleFrom(
                          backgroundColor: MyColors.blue_color,
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          )
                      ),
                      child: Text("Start fast", style: TextStyle(color: Colors.white),)
                  ),
                  const SizedBox(height: 5),
                  Text('Start fast training')
                ]
            )
        )
    );
  }
}

class NextWorkoutSection extends StatelessWidget {
  final dynamic nextTrainingInfo;

  const NextWorkoutSection({super.key, required this.nextTrainingInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Next Workout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Icon(Icons.schedule, color: MyColors.blue_color),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${nextTrainingInfo['name']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextTrainingInfo['date'] != null
                            ? "${DateTime.parse(nextTrainingInfo['date']).toIso8601String().split('T')[0]}"
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   "Duration: ~45 min",
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey[500],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/schedule/view', extra: nextTrainingInfo['id']);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: MyColors.blue_color.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "Preview",
                    style: TextStyle(color: MyColors.blue_color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickStatsSection extends StatelessWidget {
  final int practicesCount;

  const QuickStatsSection({
    super.key,
    required this.practicesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.blue_color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "$practicesCount",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColors.blue_color,
                    ),
                  ),
                  Text(
                    "Workouts",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "ND",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "Time on fire",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  "Browse Exercises",
                  Icons.fitness_center,
                      () => context.go('/exercise'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  "View Programs",
                  Icons.assignment,
                      () => context.go('/programs'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: MyColors.blue_color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MyColors.blue_color.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tools & Calculators",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Icon(Icons.calculate, color: MyColors.blue_color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "BMI, 1RM, Body Fat % and more",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/other'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Open Tools",
                style: TextStyle(
                  color: MyColors.blue_color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Navigation extends StatelessWidget {
  const Navigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,

      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/programs');
            break;
          case 1:
            context.go('/schedule');
            break;
          case 2:
            context.go('/history');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items:  [
        BottomNavigationBarItem(
          icon: dumbell,
          label: 'Programs',
        ),
        BottomNavigationBarItem(
          icon: calendar,
          label: 'Schedule',
        ),BottomNavigationBarItem(
          icon: history,
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: profile,
          label: 'Profile',
        ),
      ],
    );
  }
}
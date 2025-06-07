import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterfitapp/auth/token_script.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/pages/program_app/exercise_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/design/images.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();
final _storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Exercise> exercises = [];
  late Box<Exercise> exerciseBox;
  late RefreshToken refreshToken;

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
    _getKeys();
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
      String? _TOKEN = await _storage.read(key: 'access');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8888/api/api/exercise/'),
        headers: {
          // 'Authorization': 'Bearer $_TOKEN',
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
                        TextButton(onPressed: () =>
                            context.go('/reg'),
                            child: Text('CLICK')),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Your Smart Workout Companion — Track your progress, get personalized AI-powered practice plans, and reach your fitness goals faster..",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
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
          child: TextButton(
            onPressed: () => context.go('/fast_practice'),
            style: TextButton.styleFrom(
              backgroundColor: MyColors.blue_color,
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              )
            ),
            child: Text("Let's go train!", style: TextStyle(color: Colors.white),)
          ),
        )
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
            context.go('/exercise');
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
          icon: dumbell,
          label: 'Exercises',
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

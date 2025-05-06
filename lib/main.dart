import 'package:flutter/material.dart';
import 'package:flutterfitapp/pages/history/history.dart';
import 'package:flutterfitapp/pages/program_app/exercise.dart';
import 'package:flutterfitapp/pages/program_app/exercise_model.dart';
import 'package:flutterfitapp/pages/program_app/list_exercise.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/pages/program/program.dart';
import 'package:flutterfitapp/pages/other/other.dart';
import 'package:flutterfitapp/pages/profile/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ExerciseAdapter());
  }
  await Hive.openBox<Exercise>('exercises');
  runApp(MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'exercise',
          builder: (context, state) => const ExerciseListPage(),
        ),
        GoRoute(
          path: 'exercises',
          builder: (context, state) => const ExercisePage(),
        ),
        GoRoute(
          path: 'programs',
          builder: (context, state) => const ProgramPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: 'other',
          builder: (context, state) => const OtherPage(),
        ),
        GoRoute(
          path: 'exercises',
          builder: (context, state) => const HistoryPage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'My App',
      theme: ThemeData(
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white), // Белые иконки в AppBar
        ),
      ),
    );
  }
}



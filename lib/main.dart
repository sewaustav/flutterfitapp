import 'package:flutter/material.dart';
import 'package:flutterfitapp/pages/history/history.dart';
import 'package:flutterfitapp/pages/program/add_exercises.dart';
import 'package:flutterfitapp/pages/program/create_program.dart';
import 'package:flutterfitapp/pages/program/program_edit.dart';
import 'package:flutterfitapp/pages/program/program_view.dart';
import 'package:flutterfitapp/pages/program_app/exercise.dart';
import 'package:flutterfitapp/pages/program_app/exercise_model.dart';
import 'package:flutterfitapp/pages/program_app/list_exercise.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/pages/program/program.dart';
import 'package:flutterfitapp/pages/other/other.dart';
import 'package:flutterfitapp/pages/profile/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;




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
      builder: (context, state) => kIsWeb ? const WebMobileWrapper(child: HomePage()) : const HomePage(),
      routes: [
        GoRoute(
          path: 'exercise',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: ExerciseListPage())
              : const ExerciseListPage(),
        ),
        GoRoute(
          path: 'exercises',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: ExercisePage())
              : const ExercisePage(),
        ),
        GoRoute(
          path: 'programs',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: ProgramPage())
              : const ProgramPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: ProfilePage())
              : const ProfilePage(),
        ),
        GoRoute(
          path: 'other',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: OtherPage())
              : const OtherPage(),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: HistoryPage())
              : const HistoryPage(),
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => kIsWeb
              ? const WebMobileWrapper(child: CreateProgramPage())
              : const CreateProgramPage(),
        ),
        GoRoute(
          path: 'create_training',
          builder: (context, state) {
            final programId = state.extra as int;
            final page = AddExercisesPage(programId: programId.toString());
            return kIsWeb ? WebMobileWrapper(child: page) : page;
          },
        ),
        GoRoute(
          path: 'view_training',
          builder: (context, state) {
            final programId = state.extra as int;
            final page = ProgramViewPage(programId: programId.toString());
            return kIsWeb ? WebMobileWrapper(child: page) : page;
          },
        ),
        GoRoute(
          path: 'edit_training',
          builder: (context, state) {
            final programId = state.extra as int;
            final page = ProgramEditPage(programId: programId.toString());
            return kIsWeb ? WebMobileWrapper(child: page) : page;
          },
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

class WebMobileWrapper extends StatelessWidget {
  final Widget child;

  const WebMobileWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: child,
          ),
        ),
      ),
    );
  }
}

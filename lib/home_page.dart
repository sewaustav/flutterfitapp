import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/design/images.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            onPressed: () => context.go('/programs'),
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
            context.go('/exercises');
            break;
          case 2:
            context.go('/profile');
            break;
          case 3:
            context.go('/history');
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
        ),
        BottomNavigationBarItem(
          icon: profile,
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: history,
          label: 'History',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/design/images.dart';

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
      body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(

            children: [
              Container(
                margin: EdgeInsets.all(15),
                child: Text("Welcome guest!", style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
              ),),),
              TextButton(
                  onPressed: () => context.go('programs'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: MyColors.blue_color,
                  ),
                  child: Text("Let's train!", style: TextStyle(
                    color: Colors.white,

                  ),),),
              Container(
                margin: EdgeInsets.all(32),
                child: Text("Your results", style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                ),),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Spacer(),
            IconButton(
              onPressed: () => context.go('/exercise'),
              icon: dumbell,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/exercises'),
              icon: dumbell,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/programs'),
              icon: profile,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/profile'),
              icon: history,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

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
      body: SingleChildScrollView(child: Center(
          child: Container(

            child: Column(

            children: [
              Image.asset('assets/images/main.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),



            ],
          ),
        ),
      ),),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Spacer(),
            IconButton(
              onPressed: () => context.go('/programs'),
              icon: dumbell,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/exercises'),
              icon: dumbell,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/profile'),
              icon: profile,
            ),
            Spacer(),
            IconButton(
              onPressed: () => context.go('/history'),
              icon: history,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

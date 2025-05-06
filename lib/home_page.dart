import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterfitapp/design/images.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Container(
        child: Text('Главная'),
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

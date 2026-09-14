import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [Text("Splash Screen"), CircularProgressIndicator()],
        ),
      ),
    );
  }
}

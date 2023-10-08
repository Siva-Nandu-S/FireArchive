import 'dart:async';

import 'package:fire_archive/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MapSample())); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/FireArchive.gif',
            height: 300,
            width: 300,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const Text(
            'Loading...',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ],
      )),
    );
  }
}
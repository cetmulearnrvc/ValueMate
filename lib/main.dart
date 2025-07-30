import 'package:flutter/material.dart';
import 'package:ValuMate/screens/splash.dart';

const key_value='UserLoggedIn';
main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login',
      home : SplashScreen()
    );
  }
}
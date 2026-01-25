import 'package:flutter/material.dart';
import 'package:grad_project/features/auth/register_page.dart';
import 'package:grad_project/splash.dart';

import 'features/layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const RegisterPage(),
    );
  }
}

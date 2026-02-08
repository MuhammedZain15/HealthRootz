import 'package:flutter/material.dart';
import 'package:grad_project/switch_page.dart';

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
      home: const SwitchPage(),
    );
  }
}

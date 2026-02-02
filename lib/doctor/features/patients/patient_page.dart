// dart
import 'package:flutter/material.dart';
import 'widgets/patient_list.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: const PatientList(),
      ),
    );
  }
}
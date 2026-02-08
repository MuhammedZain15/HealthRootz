import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/doctor/doctor_layout.dart';
import 'package:grad_project/patient/features/auth/widgets/custom_button.dart';
import 'package:grad_project/patient/patient_layout.dart';

class SwitchPage extends StatelessWidget {
  const SwitchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        children: [
          CustomButton(
            filled: true,
            color: AppColors.skyBlue,
            text: "Doctor",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorAppLayout()),
              );
            },
          ),
          SizedBox(height: 30),
          CustomButton(
            filled: true,
            color: AppColors.skyBlue,
            text: "Patient",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppLayout()),
              );
            },
          ),
        ],
      ),
    );
  }
}

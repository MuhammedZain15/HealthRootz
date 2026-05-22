import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:grad_project/app_colors.dart';

import 'package:grad_project/patient/features/auth/sign_in/sign_in_page.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

import '../../../generated/assets.dart';



class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 150),
          GifView.asset(
            Assets.imagesHealthRootz,
            height: 200,
            width: 200,
            frameRate: 30,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Health",
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Text(
                "Rootz",
                style: TextStyle(
                  color: Color(0xff38B6FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          Text(
            "WE MONITOR YOUR HEALTH",
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 160),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29.0),
            child: Column(
              children: [
                CustomButton(
                  text: 'Sign In',
                  color: Color(0xff43A4F4),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  filled: true,
                  height: 48,
                  // optional: width: 300,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

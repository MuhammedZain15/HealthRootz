import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/ai_chat/ai_sessions_screen.dart';
import 'package:grad_project/patient/features/chat/chat_view.dart';
import 'package:grad_project/patient/layout/patient_widgets.dart';

void showActionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            PatientBottomSheetOption(
              icon: Icons.person,
              text: 'Chat with Doctor',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatView(isDoctorChat: true),
                  ),
                );
              },
              color: AppColors.skyBlue,
            ),
            const SizedBox(height: 10),
            PatientBottomSheetOption(
              icon: Icons.smart_toy,
              text: 'Chat with AI',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiSessionsScreen(),
                  ),
                );
              },
              color: AppColors.purple,
            ),
          ],
        ),
      );
    },
  );
}

// commit update
 
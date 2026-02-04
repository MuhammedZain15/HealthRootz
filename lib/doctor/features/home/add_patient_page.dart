import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/auth/widgets/custom_button.dart';
import 'package:grad_project/doctor/features/home/widgets/patient_page_widgets/custom_labeled_input.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Add New Patient",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              const CustomLabeledInput(
                label: "Full Name",
                hint: "Enter patient's full name",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: CustomLabeledInput(
                      label: "Age",
                      hint: "Enter age",
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: const CustomLabeledInput(
                      label: "Gender",
                      hint: "Male",
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const CustomLabeledInput(
                label: "Email Address",
                hint: "patient@email.com",
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const CustomLabeledInput(
                label: "Phone Number",
                hint: "+1 (555) 123-4567",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const CustomLabeledInput(
                label: "Medical Notes",
                hint: "Enter any relevant medical history or notes...",
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                isRequired: false,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Add Patient",
                      onPressed: () {},
                      color: AppColors.skyBlue,
                      height: 50,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      onPressed: () => Navigator.pop(context),
                      filled: false,
                      borderColor: Colors.grey[300],
                      height: 50,
                      textStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patient Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Fill in the patient information below",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileInfoCard extends StatefulWidget {
  final Map<String, String> initialData;
  final Function(Map<String, String>) onSave;

  const ProfileInfoCard({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController specialtyController;
  late TextEditingController licenseController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    emailController = TextEditingController(text: widget.initialData['email']);
    phoneController = TextEditingController(text: widget.initialData['phone']);
    specialtyController = TextEditingController(text: widget.initialData['specialty']);
    licenseController = TextEditingController(text: widget.initialData['licenseNumber']);
    addressController = TextEditingController(text: widget.initialData['address']);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specialtyController.dispose();
    licenseController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 8),
              Text(
                "Doctor Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField("Full Name", nameController),
          const SizedBox(height: 16),
          _buildTextField("Email Address", emailController),
          const SizedBox(height: 16),
          _buildTextField("Phone Number", phoneController),
          const SizedBox(height: 16),
          _buildTextField("Specialty", specialtyController),
          const SizedBox(height: 16),
          _buildTextField("License Number", licenseController),
          const SizedBox(height: 16),
          _buildTextField("Address", addressController),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSave({
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'specialty': specialtyController.text,
                  'licenseNumber': licenseController.text,
                  'address': addressController.text,
                });
              },
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text("Save Profile", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }
}

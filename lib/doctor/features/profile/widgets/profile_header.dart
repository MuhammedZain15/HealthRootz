import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String licenseNumber;
  final String address;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.licenseNumber,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    String initials = "";
    if (name.isNotEmpty) {
      List<String> parts = name.split(" ");
      if (parts.length > 1) {
        initials = (parts[0].isNotEmpty ? parts[0][0] : "") + (parts[1].isNotEmpty ? parts[1][0] : "");
      } else if (parts.isNotEmpty) {
        initials = parts[0].isNotEmpty ? parts[0][0] : "";
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            specialty,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "License No: $licenseNumber",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, email),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, phone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, address),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 20),
              label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

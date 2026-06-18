import 'package:flutter/material.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileLogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFFCA5A5)),
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// commit update
 
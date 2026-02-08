import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

class PatientBottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const PatientBottomSheetOption({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = AppColors.skyBlue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withAlpha(26), // 0.1 opacity
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientNavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final double width;
  final ValueChanged<int> onItemTapped;

  const PatientNavItem({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.width,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: width * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.skyBlue : const Color(0xff6B7280),
              size: width * 0.07,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.skyBlue : const Color(0xff6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: width * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

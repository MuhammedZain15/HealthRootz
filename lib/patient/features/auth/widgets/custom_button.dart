// dart
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool filled;
  final double height;
  final double? width;
  final TextStyle? textStyle;
  final Color? color;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.filled = true,
    this.height = 50,
    this.width,
    this.textStyle,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.darkBlue;
    final bColor = borderColor ?? bgColor;
    final radius = BorderRadius.circular(15);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: filled ? bgColor : Colors.white,
        elevation: filled ? 2 : 0,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: filled
                  ? null
                  : Border.all(color: bColor.withOpacity(0.6), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    color: filled ? Colors.white : bColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

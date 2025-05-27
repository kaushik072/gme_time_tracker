import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double width;
  final bool isLoading;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.width = double.infinity,
    this.isLoading = false,
    this.height = 48,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ?? (isPrimary ? AppColors.primary : Colors.white),
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          side: isPrimary ? null : const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
      ),
    );
  }
}

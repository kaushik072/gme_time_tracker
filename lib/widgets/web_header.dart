import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../routes/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'common_button.dart';

class WebHeader extends StatelessWidget implements PreferredSizeWidget {
  const WebHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Logo and App Name
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.onboarding),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 40),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // Auth Buttons
          CommonButton(
            text: AppStrings.logIn,
            onPressed: () {
              context.go(AppRoutes.login);
            },
            isPrimary: true,
            width: 150,
          ),
          const SizedBox(width: 16),
          CommonButton(
            text: AppStrings.signUp,
            onPressed: () {
              context.go(AppRoutes.signUp);
            },
            isPrimary: false,
            width: 150,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

import 'package:flutter/material.dart';
import 'package:gme_time_tracker/widgets/common_confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/toast_helper.dart';
import '../routes/app_routes.dart';
import '../views/profile/profile_view.dart';
import 'common_button.dart';

class WebHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isDashboard;
  final int? selectedTab;
  final Function(int)? onTabChanged;

  const WebHeader({
    super.key,
    this.isDashboard = false,
    this.selectedTab,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
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
              onTap:
                  () => context.go(
                    isDashboard ? AppRoutes.dashboard : AppRoutes.onboarding,
                  ),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 50),
                  const SizedBox(width: 8),
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

          // Show navigation tabs only for dashboard, aligned to the right
          if (isDashboard) ...[
            _buildTab('Tracking', 0, Icons.timer),
            const SizedBox(width: 24),
            _buildTab('Activity', 1, Icons.list_alt),
            const SizedBox(width: 24),
            _buildTab('Summary', 2, Icons.bar_chart),
            const SizedBox(width: 32),
          ],

          // Show different actions based on screen
          if (isDashboard)
            // Profile/Logout Menu for dashboard
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline),
                          SizedBox(width: 8),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) async {
                if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder:
                        (context) => CommonConfirmDialog(
                          title: 'Log Out',
                          content: 'Are you sure you want to logout?',
                          onConfirm: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              ToastHelper.showSuccessToast(
                                'Successfully logged out',
                              );
                              context.go('/login');
                            }
                          },
                          confirmText: 'Logout',
                        ),
                  );
                } else if (value == 'profile') {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              width: 800,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Profile',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          icon: Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ProfileView(canBack: true),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    );
                  }
                }
              },
            )
          else ...[
            // Login/Signup buttons for onboarding
            CommonButton(
              text: AppStrings.logIn,
              onPressed: () => context.go(AppRoutes.login),
              isPrimary: true,
              width: 150,
            ),
            const SizedBox(width: 16),
            CommonButton(
              text: AppStrings.signUp,
              onPressed: () => context.go(AppRoutes.signUp),
              isPrimary: false,
              width: 150,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index, IconData icon) {
    if (selectedTab == null || onTabChanged == null)
      return const SizedBox.shrink();

    final isSelected = selectedTab == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTabChanged!(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

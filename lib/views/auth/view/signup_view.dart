import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/utils/constants_data.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/common_button.dart';
import '../../../widgets/common_input_field.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/web_header.dart';
import '../controller/auth_controller.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      webBody: _WebSignUpView(),
      mobileBody: _MobileSignUpView(),
    );
  }
}

class _WebSignUpView extends StatelessWidget {
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebHeader(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.all(50),

            decoration: BoxDecoration(
              // color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your information to create your GME Time Tracker account',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                _buildSignUpForm(
                  onLogin: () => context.go(AppRoutes.login),
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm({required VoidCallback onLogin, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: controller.firstNameController,
                labelText: 'First Name',
                hintText: 'Enter your first name',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonTextField(
                controller: controller.lastNameController,
                labelText: 'Last Name',
                hintText: 'Enter your last name',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonTextField(
            controller: controller.passwordController,
            labelText: 'Password',
            hintText: '••••••••',
            obscureText: controller.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonTextField(
            controller: controller.confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: '••••••••',
            obscureText: controller.obscureConfirmPassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureConfirmPassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => CommonDropdownButton<String>(
                  value:
                      controller.selectedDegree.value.isEmpty
                          ? null
                          : controller.selectedDegree.value,
                  labelText: 'Degree',
                  hintText: 'Select Degree',
                  items: const [
                    DropdownMenuItem(
                      value: 'bachelor',
                      child: Text('Bachelor'),
                    ),
                    DropdownMenuItem(value: 'master', child: Text('Master')),
                    DropdownMenuItem(value: 'phd', child: Text('PhD')),
                  ],
                  onChanged:
                      (value) => controller.selectedDegree.value = value ?? '',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => CommonDropdownButton<String>(
                  value:
                      controller.selectedPosition.value.isEmpty
                          ? null
                          : controller.selectedPosition.value,
                  labelText: 'Position',
                  hintText: 'Select Position',
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(
                      value: 'professor',
                      child: Text('Professor'),
                    ),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged:
                      (value) =>
                          controller.selectedPosition.value = value ?? '',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Obx(
          () => CommonButton(
            text: 'Create Account',
            onPressed: () => controller.signUp(context),
            isPrimary: true,
            width: double.infinity,
            isLoading: controller.isLoading.value,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(onPressed: onLogin, child: const Text('Log in')),
          ],
        ),
      ],
    );
  }
}

class _MobileSignUpView extends StatelessWidget {
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/logo.png', height: 60)),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Enter your information to create your GME Time Tracker account',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              _buildSignUpForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: controller.firstNameController,
          labelText: 'First Name',
          hintText: 'Enter your first name',
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: controller.lastNameController,
          labelText: 'Last Name',
          hintText: 'Enter your last name',
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonTextField(
            controller: controller.passwordController,
            labelText: 'Password',
            hintText: '••••••••',
            obscureText: controller.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonTextField(
            controller: controller.confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: '••••••••',
            obscureText: controller.obscureConfirmPassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureConfirmPassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonDropdownButton<String>(
            value:
                controller.selectedDegree.value.isEmpty
                    ? null
                    : controller.selectedDegree.value,
            labelText: 'Degree',
            hintText: 'Select Degree',
            items: ConstantsData.instance.getDegreeItems(),
            onChanged: (value) => controller.selectedDegree.value = value ?? '',
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => CommonDropdownButton<String>(
            value:
                controller.selectedPosition.value.isEmpty
                    ? null
                    : controller.selectedPosition.value,
            labelText: 'Position',
            hintText: 'Select Position',
            items: ConstantsData.instance.getPositionItems(),
            onChanged:
                (value) => controller.selectedPosition.value = value ?? '',
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => CommonButton(
            text: 'Create Account',
            onPressed: () => controller.signUp(context),
            isPrimary: true,
            width: double.infinity,
            isLoading: controller.isLoading.value,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Log in'),
            ),
          ],
        ),
      ],
    );
  }
}

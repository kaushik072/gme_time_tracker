import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/utils/toast_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:gme_time_tracker/repositories/auth_repository.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final selectedDegree = ''.obs;
  final selectedPosition = ''.obs;

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> login(BuildContext context) async {
    if (!_validateLoginFields()) return;

    try {
      isLoading.value = true;
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        navigationToDashboard(context);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      ToastHelper.showErrorToast('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(BuildContext context) async {
    if (!_validateSignUpFields()) return;

    try {
      isLoading.value = true;
      final userCredential = await _authRepository
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      if (userCredential.user != null) {
        await _authRepository.createUserDocument(
          uid: userCredential.user!.uid,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          degree: selectedDegree.value,
          position: selectedPosition.value,
        );

        navigationToDashboard(context);
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      ToastHelper.showErrorToast('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  void navigationToDashboard(BuildContext context) {
    debugPrint('Success: User authenticated successfully');
    context.go(AppRoutes.dashboard);
  }

  bool _validateLoginFields() {
    if (emailController.text.isEmpty || !emailController.text.isEmail) {
      ToastHelper.showErrorToast('Please enter a valid email address');
      return false;
    }
    if (passwordController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your password');
      return false;
    }
    return true;
  }

  bool _validateSignUpFields() {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your first and last name');
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.isEmail) {
      ToastHelper.showErrorToast('Please enter a valid email address');
      return false;
    }
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter and confirm your password');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ToastHelper.showErrorToast('Passwords do not match');
      return false;
    }
    if (selectedDegree.isEmpty || selectedPosition.isEmpty) {
      ToastHelper.showErrorToast('Please select your degree and position');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

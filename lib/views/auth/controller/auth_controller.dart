import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
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

  Future<void> login() async {
    if (!_validateLoginFields()) return;
    
    try {
      isLoading.value = true;
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!_validateSignUpFields()) return;

    try {
      isLoading.value = true;
      // TODO: Implement signup logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateLoginFields() {
    if (emailController.text.isEmpty || !emailController.text.isEmail) {
      // Show error
      return false;
    }
    if (passwordController.text.isEmpty) {
      // Show error
      return false;
    }
    return true;
  }

  bool _validateSignUpFields() {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      // Show error
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.isEmail) {
      // Show error
      return false;
    }
    if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      // Show error
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      // Show error
      return false;
    }
    if (selectedDegree.isEmpty || selectedPosition.isEmpty) {
      // Show error
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
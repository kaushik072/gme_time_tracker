import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gme_time_tracker/utils/toast_helper.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      if (userCredential.user != null) {
        navigationToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      ToastHelper.showErrorToast(e.message ?? 'An error occurred during login');
    } catch (e) {
      debugPrint('Login error: $e');
      ToastHelper.showErrorToast('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!_validateSignUpFields()) return;

    try {
      isLoading.value = true;
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      if (userCredential.user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'degree': selectedDegree.value,
          'position': selectedPosition.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        navigationToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup error: ${e.message}');
      ToastHelper.showErrorToast(
        e.message ?? 'An error occurred during signup',
      );
    } catch (e) {
      debugPrint('Signup error: $e');
      ToastHelper.showErrorToast('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  void navigationToDashboard() {
    debugPrint('Success: User authenticated successfully');
    // TODO: Implement navigation to dashboard
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

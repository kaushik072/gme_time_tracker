import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/repositories/auth_repository.dart';
import 'package:gme_time_tracker/utils/toast_helper.dart';
import 'package:gme_time_tracker/widgets/common_button.dart';
import 'package:gme_time_tracker/widgets/common_input_field.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupFirstNameController = TextEditingController();
  final signupLastNameController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  final otherDegreeController = TextEditingController();
  final otherPositionController = TextEditingController();

  clearAllControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
    signupFirstNameController.clear();
    signupLastNameController.clear();
    signupConfirmPasswordController.clear();
    otherDegreeController.clear();
    otherPositionController.clear();
    forgotPasswordEmailController.clear();
  }

  final selectedDegree = ''.obs;
  final selectedPosition = ''.obs;

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  RxBool isOtherDegree = false.obs;
  RxBool isOtherPosition = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  final forgotPasswordEmailController = TextEditingController();

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    try {
      String email = forgotPasswordEmailController.text.trim();
      if (email.isEmpty || !email.isEmail) {
        ToastHelper.showErrorToast('Please enter a valid email address');
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
      ToastHelper.showSuccessToast('Password reset email sent to $email');
      GoRouter.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ToastHelper.showErrorToast(e.message ?? 'An unexpected error occurred');
    } catch (e) {
      ToastHelper.showErrorToast('An unexpected error occurred');
    }
  }

  Future<void> showForgotPasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => GoRouter.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: forgotPasswordEmailController,
                  hintText: 'Enter your email',
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s+')),
                  ],
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CommonButton(
                  text: 'Send',
                  onPressed: () => sendPasswordResetEmail(context),
                  isPrimary: true,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
    forgotPasswordEmailController.clear();
  }

  Future<void> login(BuildContext context) async {
    if (!_validateLoginFields()) return;

    try {
      isLoading.value = true;
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      if (userCredential.user != null) {
        clearAllControllers();
        navigationToDashboard(context);
      }
    } on FirebaseAuthException catch (e) {
      ToastHelper.showErrorToast(e.message ?? 'An unexpected error occurred');
    } catch (e) {
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
            email: signupEmailController.text.trim(),
            password: signupPasswordController.text.trim(),
          );

      if (userCredential.user != null) {
        String otherDegree = otherDegreeController.text.trim();
        String otherPosition = otherPositionController.text.trim();

        if (otherDegree.isNotEmpty) {
          otherDegree = otherDegree[0].toUpperCase() + otherDegree.substring(1);
        }

        if (otherPosition.isNotEmpty) {
          otherPosition =
              otherPosition[0].toUpperCase() + otherPosition.substring(1);
        }

        await _authRepository.createUserDocument(
          uid: userCredential.user!.uid,
          firstName: signupFirstNameController.text.trim(),
          lastName: signupLastNameController.text.trim(),
          email: signupEmailController.text.trim(),
          degree: isOtherDegree.isTrue ? otherDegree : selectedDegree.value,
          position:
              isOtherPosition.isTrue ? otherPosition : selectedPosition.value,
        );
        clearAllControllers();
        navigationToDashboard(context);
      }
    } on FirebaseAuthException catch (e) {
      ToastHelper.showErrorToast(e.message ?? 'An unexpected error occurred');
    } catch (e) {
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
    if (loginEmailController.text.isEmpty ||
        !loginEmailController.text.isEmail) {
      ToastHelper.showErrorToast('Please enter a valid email address');
      return false;
    }
    if (loginPasswordController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your password');
      return false;
    }
    return true;
  }

  bool _validateSignUpFields() {
    if (signupFirstNameController.text.isEmpty ||
        signupLastNameController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your first and last name');
      return false;
    }
    if (signupEmailController.text.isEmpty ||
        !signupEmailController.text.isEmail) {
      ToastHelper.showErrorToast('Please enter a valid email address');
      return false;
    }
    if (signupPasswordController.text.isEmpty ||
        signupConfirmPasswordController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter and confirm your password');
      return false;
    }
    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      ToastHelper.showErrorToast('Passwords do not match');
      return false;
    }
    if (selectedDegree.isEmpty || selectedPosition.isEmpty) {
      ToastHelper.showErrorToast('Please select your degree and position');
      return false;
    }
    if (isOtherDegree.isTrue && otherDegreeController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your degree');
      return false;
    }
    if (isOtherPosition.isTrue && otherPositionController.text.isEmpty) {
      ToastHelper.showErrorToast('Please enter your position');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupFirstNameController.dispose();
    signupLastNameController.dispose();
    signupConfirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}

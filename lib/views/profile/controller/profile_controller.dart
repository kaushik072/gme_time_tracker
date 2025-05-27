import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/routes/app_routes.dart';
import 'package:gme_time_tracker/views/auth/view/login_view.dart';
import 'package:gme_time_tracker/views/dashboard/controller/dashboard_controller.dart';
import 'package:gme_time_tracker/widgets/common_button.dart';
import 'package:gme_time_tracker/widgets/common_input_field.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../../utils/constants_data.dart';
import '../../../utils/toast_helper.dart';

class ProfileController extends GetxController {
  final DashboardController dashboardController = Get.find();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final institutionController = TextEditingController();
  final specialtyController = TextEditingController();
  final otherDegreeController = TextEditingController();
  final otherPositionController = TextEditingController();

  final isEditing = false.obs;
  Rx<String?> degree = Rx<String?>(null);
  Rx<String?> position = Rx<String?>(null);

  late final List<DropdownMenuItem<String>> degreeItems;
  late final List<DropdownMenuItem<String>> positionItems;
  @override
  void onInit() {
    super.onInit();
    degreeItems = ConstantsData.instance.getDegreeItems();
    positionItems = ConstantsData.instance.getPositionItems();
    setUserData();
  }

  setUserData() {
    UserModel? user = dashboardController.user.value;
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';

    emailController.text = user?.email ?? '';
    institutionController.text = user?.institution ?? '';
    specialtyController.text = user?.specialty ?? '';

    degree.value = getDegree()?.toLowerCase().trim();
    // degree.value = user?.degree.toLowerCase().trim();

    position.value = getPosition()?.toLowerCase().trim();
    // position.value = user?.position.toLowerCase().trim();
  }

  String? getDegree() {
    String? degree;
    for (var element in ConstantsData.instance.degrees) {
      UserModel? user = dashboardController.user.value;
      if (element.toLowerCase() == user?.degree) {
        degree = user?.degree;
        break;
      } else {
        degree = "Others";
        otherDegreeController.text = user?.degree.capitalizeFirst ?? '';
      }
    }
    return degree;
  }

  String? getPosition() {
    String? position;
    for (var element in ConstantsData.instance.positions) {
      UserModel? user = dashboardController.user.value;
      if (element.toLowerCase() == user?.position) {
        position = user?.position;
        break;
      } else {
        position = "Others";
        otherPositionController.text = user?.position.capitalizeFirst ?? '';
      }
    }
    return position;
  }

  void startEditing() {
    isEditing.value = true;
  }

  void cancelEditing() {
    setUserData();
    isEditing.value = false;
  }

  void close(BuildContext context) {
    context.pop();
  }

  Future<bool> saveChanges() async {
    if (degree.value == "others" || position.value == "others") {
      if (degree.value == "others") {
        if (otherDegreeController.text.isEmpty) {
          ToastHelper.showErrorToast('Please enter degree');
          return false;
        }
      }
      if (position.value == "others") {
        if (otherPositionController.text.isEmpty) {
          ToastHelper.showErrorToast('Please enter position');
          return false;
        }
      }
    }
    try {
      bool isUpdated = await dashboardController.updateUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        degree:
            degree.value == "others"
                ? otherDegreeController.text
                : degree.value,
        position:
            position.value == "others"
                ? otherPositionController.text
                : position.value,
        institution: institutionController.text.trim(),
        specialty: specialtyController.text.trim(),
      );
      isEditing.value = false;
      await Future.delayed(const Duration(seconds: 1), () {
        setUserData();
      });
      return isUpdated;
    } catch (e) {
      ToastHelper.showErrorToast('Failed to update profile');
      return false;
    }
  }

  TextEditingController deleteAccountEmailController = TextEditingController();
  TextEditingController deleteAccountPasswordController =
      TextEditingController();

  RxBool deleteAccountPasswordVisible = false.obs;

  Future<void> showDeleteAccountDialog(BuildContext context) async {
    context.pop();
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
                  controller: deleteAccountEmailController,
                  hintText: 'Enter your email',
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s+')),
                  ],
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CommonTextField(
                    obscureText: deleteAccountPasswordVisible.value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        deleteAccountPasswordVisible.value =
                            !deleteAccountPasswordVisible.value;
                      },
                      icon: Icon(
                        deleteAccountPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    controller: deleteAccountPasswordController,
                    hintText: 'Enter your password',
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s+')),
                    ],
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
                const SizedBox(height: 16),
                CommonButton(
                  text: 'Delete Account',
                  onPressed: () async {
                    // try {
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      // Step 1: Re-authenticate
                      // AuthCredential credential = EmailAuthProvider.credential(
                      // email: deleteAccountEmailController.text.trim(),
                      // password: deleteAccountPasswordController.text.trim(),
                      // );
                      // await user.reauthenticateWithCredential(credential);

                      // Step 2: Delete the account
                      // await user.delete();

                      // context.pop();
                      // await Future.delayed(const Duration(seconds: 1), () {
                      //   if (context.mounted) {
                      ToastHelper.showSuccessToast(
                        'Account deleted successfully.',
                      );
                      if (context.mounted) {
                        context.go('/login');
                      }

                      // Get.offAllNamed("/login");

                      // Navigator.pushAndRemoveUntil(
                      // context,
                      //   MaterialPageRoute(builder: (context) => const LoginView()),
                      //   (route) => true,
                      // );
                    }
                    // } on FirebaseAuthException catch (e) {
                    //   ToastHelper.showErrorToast(e.message ?? 'Error deleting account');
                    // } catch (e) {
                    //   ToastHelper.showErrorToast('Error deleting account: $e');
                    // }
                  },
                  isPrimary: false,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );

    deleteAccountEmailController.clear();
    deleteAccountPasswordController.clear();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    otherDegreeController.dispose();
    otherPositionController.dispose();
    super.onClose();
  }
}

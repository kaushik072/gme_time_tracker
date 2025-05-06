import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/views/dashboard/controller/dashboard_controller.dart';
import 'package:go_router/go_router.dart';
import '../../../models/user_model.dart';
import '../../../utils/toast_helper.dart';
import '../../../utils/constants_data.dart';

class ProfileController extends GetxController {
  final DashboardController dashboardController = Get.find();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

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

    degree.value = user?.degree.toLowerCase().trim();

    position.value = user?.position.toLowerCase().trim();
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
    try {
      bool isUpdated = await dashboardController.updateUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        degree: degree.value,
        position: position.value ?? '',
      );
      isEditing.value = false;
      Future.delayed(const Duration(seconds: 1), () {
        setUserData();
      });
      return isUpdated;
    } catch (e) {
      ToastHelper.showErrorToast('Failed to update profile');
      return false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

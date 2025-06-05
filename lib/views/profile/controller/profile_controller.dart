import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/views/dashboard/controller/dashboard_controller.dart';
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

  @override
  void onInit() {
    super.onInit();

    setUserData();
  }

  setUserData() {
    UserModel? user = dashboardController.user.value;
    firstNameController.text = user?.firstName ?? '';
    lastNameController.text = user?.lastName ?? '';
    emailController.text = user?.email ?? '';
    institutionController.text = user?.institution ?? '';
    specialtyController.text = user?.specialty ?? '';
    degree.value = user?.degree;
    position.value = user?.position;
    bool isDegreeOther = ConstantsData.instance.degrees.contains(degree.value);
    if (!isDegreeOther) {
      degree.value = "Other";
      otherDegreeController.text = user?.degree ?? '';
    } else {
      otherDegreeController.text = '';
      degree.value = user?.degree;
    }

    print(ConstantsData.instance.positions);
    print(user?.position);

    bool isPositionOther = ConstantsData.instance.positions.contains(
      position.value,
    );
    print(isPositionOther);
    if (!isPositionOther) {
      position.value = "Other";
      otherPositionController.text = user?.position ?? '';
    } else {
      otherPositionController.text = '';
      position.value = user?.position;
    }
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
      String otherDegree = otherDegreeController.text.trim();
      String otherPosition = otherPositionController.text.trim();
      String specialty = specialtyController.text.trim();
      String institution = institutionController.text.trim();

      if (specialty.isNotEmpty) {
        specialty = specialty[0].toUpperCase() + specialty.substring(1);
      }
      if (institution.isNotEmpty) {
        institution = institution[0].toUpperCase() + institution.substring(1);
      }
      if (otherDegree.isNotEmpty) {
        otherDegree = otherDegree[0].toUpperCase() + otherDegree.substring(1);
      }
      if (otherPosition.isNotEmpty) {
        otherPosition =
            otherPosition[0].toUpperCase() + otherPosition.substring(1);
      }

      bool isUpdated = await dashboardController.updateUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        degree: degree.value == "Other" ? otherDegree : degree.value,
        position: position.value == "Other" ? otherPosition : position.value,
        institution: institution,
        specialty: specialty,
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
    otherDegreeController.dispose();
    otherPositionController.dispose();
    super.onClose();
  }
}

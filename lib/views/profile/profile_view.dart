import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/common_button.dart';
import '../../widgets/common_input_field.dart';
import 'controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.canBack = false});
  final bool canBack;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canBack) ...[
              Text(
                'Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
            Obx(
              () => IgnorePointer(
                ignoring: !controller.isEditing.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return CommonDropdownButton<String?>(
                        labelText: 'Degree',
                        hintText: 'Select Degree',
                        value: controller.degree.value,
                        items: controller.degreeItems,
                        onChanged: (value) {
                          controller.degree.value = value ?? '';
                          print(
                            "controller.degree.value: ${controller.degree.value}",
                          );
                          print("value: $value");
                        },
                      );
                    }),
                    Obx(
                      () => Visibility(
                        visible: controller.degree.value == "others",
                        child: CommonTextField(
                          controller: controller.otherDegreeController,
                        ).paddingOnly(top: 5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return CommonDropdownButton<String?>(
                        labelText: 'Position',
                        hintText: 'Select Position',
                        value: controller.position.value,
                        items: controller.positionItems,
                        onChanged: (value) {
                          controller.position.value = value ?? '';
                        },
                      );
                    }),
                    Obx(
                      () => Visibility(
                        visible: controller.position.value == "others",
                        child: CommonTextField(
                          controller: controller.otherPositionController,
                        ).paddingOnly(top: 5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CommonTextField(
                      controller: controller.institutionController,
                      labelText: 'Institution',
                      hintText: 'Enter your institution',
                    ),

                    const SizedBox(height: 16),
                    CommonTextField(
                      controller: controller.specialtyController,
                      labelText: 'Specialty',
                      hintText: 'Enter your specialty',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Obx(
              () =>
                  controller.isEditing.value
                      ? Row(
                        children: [
                          Expanded(
                            child: CommonButton(
                              text: 'Cancel',
                              onPressed: controller.cancelEditing,
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CommonButton(
                              text: 'Save Changes',
                              onPressed: () async {
                                bool isUpdated = await controller.saveChanges();
                                if (isUpdated && context.mounted && canBack) {
                                  controller.close(context);
                                }
                              },
                              isPrimary: true,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        children: [
                          if (canBack) ...[
                            Expanded(
                              child: CommonButton(
                                text: 'Close',
                                onPressed: () => controller.close(context),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: CommonButton(
                              text: 'Edit Profile',
                              onPressed: controller.startEditing,
                              isPrimary: true,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        );
      },
    );
  }
}

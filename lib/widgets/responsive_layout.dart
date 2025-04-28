import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget webBody;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.webBody,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context) ? appBar : null,
      drawer: isMobile(context) ? drawer : null,
      bottomNavigationBar: isMobile(context) ? bottomNavigationBar : null,
      body: GetBuilder<ResponsiveController>(
        init: ResponsiveController(),
        builder: (controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return mobileBody;
              }
              return webBody;
            },
          );
        },
      ),
    );
  }
}

class ResponsiveController extends GetxController {
  bool get isMobile => Get.width < 850;
  bool get isWeb => Get.width >= 850;
} 
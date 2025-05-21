import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/web_header.dart';
import '../../widgets/common_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      webBody: _WebHomeView(),
      mobileBody: _MobileHomeView(),
    );
  }
}

class _WebHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/logo.png', height: 120),
                  const SizedBox(height: 50),
                  const Text(
                    AppStrings.mainTitle,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 600,
                    child: Text(
                      AppStrings.mainDescription,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 80),
              child: SizedBox(
                height: 220,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _FeatureCard(
                        icon: Icons.timer,
                        title: AppStrings.timeTrackingTitle,
                        description: AppStrings.timeTrackingDesc,
                      ),
                    ),
                    SizedBox(width: 40),
                    Flexible(
                      child: _FeatureCard(
                        icon: Icons.description,
                        title: AppStrings.reportsTitle,
                        description: AppStrings.reportsDesc,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 80),
            // const WebFooter(),
          ],
        ),
      ),
    );
  }
}

class _MobileHomeView extends StatefulWidget {
  @override
  State<_MobileHomeView> createState() => _MobileHomeViewState();
}

class _MobileHomeViewState extends State<_MobileHomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Spacer(),
            Image.asset('assets/logo.png', height: 100),
            const Spacer(),

            const Text(
              AppStrings.mainTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.mainDescription,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              height: 200,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  const _FeatureCard(
                    isMobile: true,
                    icon: Icons.timer,
                    title: AppStrings.timeTrackingTitle,
                    description: AppStrings.timeTrackingDesc,
                  ),
                  const _FeatureCard(
                    isMobile: true,
                    icon: Icons.description,
                    title: AppStrings.reportsTitle,
                    description: AppStrings.reportsDesc,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? AppColors.primary
                            : AppColors.border,
                  ),
                );
              }),
            ),
            const Spacer(),

            CommonButton(
              text: AppStrings.logIn,
              onPressed: () {
                context.go(AppRoutes.login);
              },
              isPrimary: true,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            CommonButton(
              text: AppStrings.signUp,
              onPressed: () {
                context.go(AppRoutes.signUp);
              },
              isPrimary: false,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isMobile;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 15 : 30),
      constraints: const BoxConstraints(maxWidth: 500, minWidth: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isMobile ? 30 : 40, color: AppColors.accent),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

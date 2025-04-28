import 'package:go_router/go_router.dart';
import '../views/auth/view/login_view.dart';
import '../views/auth/view/signup_view.dart';
import '../views/onboarding/onboarding_view.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signUp = '/signup';

  static final router = GoRouter(
    initialLocation: onboarding,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpView(),
      ),
    ],
  );

  // Route names for easy reference
  static const String dashboard = '/dashboard';
} 
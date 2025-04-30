import 'package:go_router/go_router.dart';
import '../utils/auth_service.dart';
import '../views/auth/view/login_view.dart';
import '../views/auth/view/signup_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/onboarding/onboarding_view.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';

  // List of public routes that don't require authentication
  static final List<String> publicRoutes = [
    onboarding,
    login,
    signUp,
    dashboard,
  ];

  static final router = GoRouter(
    initialLocation: dashboard,
    redirect: (context, state) {
      final isAuthenticated = AuthService.isAuthenticated;
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // If not authenticated and trying to access private route
      if (!isAuthenticated && !isPublicRoute) {
        return login;
      }

      // If authenticated and trying to access auth routes (login, signup, onboarding)
      if (isAuthenticated && isPublicRoute) {
        return dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginView()),
      GoRoute(path: signUp, builder: (context, state) => const SignUpView()),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardView(),
      ),
    ],
  );
}

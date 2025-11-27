import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/features/home/presentation/home_page.dart';
import 'package:flutter_application/features/theme_mode/presentation/page/theme_mode__page.dart';
import 'package:flutter_application/features/user/presentation/page/change_email_address_page.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application/features/auth/presentation/page/login_callback_page.dart';
import 'package:flutter_application/features/auth/presentation/page/register_page.dart';
import 'package:flutter_application/features/onboarding/presentation/page/onboarding_page.dart';
import 'package:flutter_application/features/splash/presentation/page/splash_page.dart';
import '../../features/auth/presentation/page/login_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      name: Routes.initial.name,
      path: Routes.initial.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: Routes.splash.name,
      path: Routes.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: Routes.onboarding.name,
      path: Routes.onboarding.path,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      name: Routes.login.name,
      path: Routes.login.path,
      builder: (context, state) {
        final isLoginMode = state.extra as bool? ?? true;
        return LoginPage(isLoginMode: isLoginMode);
      },
    ),
    GoRoute(
      name: Routes.home.name,
      path: Routes.home.path,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: Routes.changeEmailAddress.name,
      path: Routes.changeEmailAddress.path,
      builder: (context, state) => const ChangeEmailAddressPage(),
    ),
    GoRoute(
      name: Routes.themeMode.name,
      path: Routes.themeMode.path,
      builder: (context, state) => const ThemeModePage(),
    ),
    GoRoute(
      name: Routes.loginCallback.name,
      path: Routes.loginCallback.path,
      builder: (context, state) => const LoginCallbackPage(),
    ),
    GoRoute(
      name: Routes.register.name,
      path: Routes.register.path,
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);

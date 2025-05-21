import 'package:get/get.dart';
import 'package:moneyvesto/features/chatbot/chatbot_screen.dart';
import 'package:moneyvesto/features/forgot_password/forgot_password_screen.dart';
import 'package:moneyvesto/features/home/home_screen.dart';
import 'package:moneyvesto/features/login/login_screen.dart';
import 'package:moneyvesto/features/onboarding/onboarding_screen.dart';
import 'package:moneyvesto/features/profile/profile_screen.dart';
import 'package:moneyvesto/features/reports/finance_report_screen.dart';
import 'package:moneyvesto/features/signup/signup_screen.dart';
import 'package:moneyvesto/features/splash/splash_screen.dart';

class NavigationRoutes {
  static String initial = '/';
  static String onboarding = '/onboarding';
  static String login = '/login';
  static String signUp = '/sign-up';
  static String forgotPassword = '/forgot-password';
  static String home = '/home';
  static String profile = '/profile';
  static String financeReport = '/finance-report';
  static String chatBot = '/chatbot';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: home, page: () => const HomeScreen(),),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: financeReport, page: () => const FinanceReportScreen()),
    GetPage(name: chatBot, page: () => const ChatbotScreen()),
  ];
}

import 'package:get/get.dart';
import 'package:moneyvesto/features/analytics/analytics_screen.dart';
import 'package:moneyvesto/features/chatbot/chatbot_screen.dart';
import 'package:moneyvesto/features/forgot_password/forgot_password_screen.dart';
import 'package:moneyvesto/features/get_started/get_started_screen.dart';
import 'package:moneyvesto/features/home/home_screen.dart';
import 'package:moneyvesto/features/invest/invest_screen.dart';
import 'package:moneyvesto/features/login/login_screen.dart';
import 'package:moneyvesto/features/news/news_screen.dart';
import 'package:moneyvesto/features/onboarding/onboarding_screen.dart';
import 'package:moneyvesto/features/profile/profile_screen.dart';
import 'package:moneyvesto/features/reports/finance_report_screen.dart';
import 'package:moneyvesto/features/signup/signup_screen.dart';
import 'package:moneyvesto/features/splash/splash_screen.dart';
import 'package:moneyvesto/features/budget/budget_screen.dart';
import 'package:moneyvesto/features/gamification/gamification_screen.dart';

class NavigationRoutes {
  static String initial = '/';
  static String onboarding = '/onboarding';
  static String getStarted = '/get-started'; // Optional, if you have a get started screen
  static String login = '/login';
  static String signUp = '/sign-up';
  static String forgotPassword = '/forgot-password';
  static String home = '/home';
  static String profile = '/profile';
  static String financeReport = '/finance-report';
  static String chatBot = '/chatbot';
  static String invest = '/invest';
  static String news = '/news';
  static String analytics = '/analytics'; // Optional, if you have a settings screen
  static String budget = '/budget';
  static String gamification = '/gamification';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: getStarted, page: () => const GetStartedScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: home, page: () => const HomeScreen(),),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: financeReport, page: () => const FinanceReportScreen()),
    GetPage(name: chatBot, page: () => const ChatbotScreen()),
    GetPage(name: invest, page: () => const EducationAndSimulationScreen()),
    GetPage(name: news, page: () => const NewsScreen()),
    GetPage(name: analytics, page: () => const AnalyticsScreen()), // Uncomment if you have a settings screen
    GetPage(name: budget, page: () => const BudgetScreen()),
    GetPage(name: gamification, page: () => const GamificationScreen()),
  ];
}

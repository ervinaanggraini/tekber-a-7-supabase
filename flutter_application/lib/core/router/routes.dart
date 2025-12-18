enum Routes {
  initial(
    name: "initial",
    path: "/",
  ),
  login(
    name: "login",
    path: "/login",
  ),
  home(
    name: "home",
    path: "/home",
  ),
  settings(
    name: "settings",
    path: "/settings",
  ),
  changeEmailAddress(
    name: "changeEmailAddress",
    path: "/changeEmailAddress",
  ),
  themeMode(
    name: "themeMode",
    path: "/themeMode",
  ),
  loginCallback(
    name: "loginCallback",
    path: "/login-callback",
  ),
  splash(
    name: "splash",
    path: "/splash",
  ),
  onboarding(
    name: "onboarding",
    path: "/onboarding",
  ),
  register(
    name: "register",
    path: "/register",
  ),
  chat(
    name: "chat",
    path: "/chat",
  ),
  budget(
    name: "budget",
    path: "/budget",
  ),
  savingsGoal(
    name: "savingsGoal",
    path: "/savingsGoal",
  ),
  financialInsights(
    name: "financialInsights",
    path: "/financialInsights",
  ),
  notifications(
    name: "notifications",
    path: "/notifications",
  ),
  ocr(
    name: "ocr",
    path: "/ocr",
  ),
  education(
    name: "education",
    path: "/education",
  ),
  invest(
    name: "invest",
    path: "/invest",
  ),
  portfolio(
    name: 'portfolio',
    path: '/portfolio',
  );





  const Routes({
    required this.path,
    required this.name,
  });

  final String path;
  final String name;
}

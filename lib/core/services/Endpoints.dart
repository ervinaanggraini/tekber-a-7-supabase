class Endpoints {
  // Base URL configuration
  // Use 10.0.2.2 for Android Emulator, localhost/127.0.0.1 for Windows/Web
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  // User Endpoints
  static const String register = '$baseUrl/users/register';
  static const String login = '$baseUrl/users/login';
  static const String currentUser = '$baseUrl/users/me';
  static const String logout = '$baseUrl/users/logout';

  // Transaction Endpoints
  static const String transactions = '$baseUrl/transactions';

  // Budget Endpoints
  static const String budgets = '$baseUrl/budgets';

  // Transaction by ID Endpoint
  static String transactionById(String id) => '$baseUrl/transactions/$id';
}

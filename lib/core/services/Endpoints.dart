class Endpoints {
  static const String baseUrl = 'http://45.13.132.219:5000/api';

  // User Endpoints
  static const String register = '$baseUrl/users/register';
  static const String login = '$baseUrl/users/login';
  static const String currentUser = '$baseUrl/users/me';
  static const String logout = '$baseUrl/users/logout';

  // Transaction Endpoints
  static const String transactions = '$baseUrl/transactions';
  static String transactionById(String id) => '$baseUrl/transactions/$id';
}

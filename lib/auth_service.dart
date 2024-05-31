// lib/auth_service.dart

class AuthService {
  static const List<String> allowedUsers = ['David', 'user2', 'user3'];

  static bool isUserAllowed(String username) {
    return allowedUsers.contains(username);
  }
}

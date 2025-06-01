// user_store.dart
import 'package:flutter/foundation.dart';

class UserStore {
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  final Map<String, String> _users = {};

  // Store user profile details
  String? _currentEmail;
  String? _currentFullName;
  String? _currentPhone;
  String? _currentPassword;
  String? _profileImagePath;  // <-- private backing field for image path

  // Getter for profile image path
  String? get profileImagePath => _profileImagePath;

  // Setter to update profile image path
  set profileImagePath(String? path) {
    _profileImagePath = path;
    if (kDebugMode) {
      print('Profile image path updated: $path');
    }
  }

  void registerUser(String email, String password, {
    required String fullName,
    required String phone,
  }) {
    _users[email] = password;
    _currentEmail = email;
    _currentFullName = fullName;
    _currentPhone = phone;
    _currentPassword = password;

    if (kDebugMode) {
      print("User registered: $fullName, $email");
    }
  }

  bool userExists(String email) => _users.containsKey(email);

  bool validateUser(String email, String password) {
    if (_users[email] == password) {
      _currentEmail = email;
      _currentPassword = password;
      return true;
    }
    return false;
  }

  String? get email => _currentEmail;
  String? get fullName => _currentFullName;
  String? get phone => _currentPhone;
  String? get password => _currentPassword;

  void updateUserInfo({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? profileImagePath,  // optional parameter for image path
  }) {
    _currentFullName = fullName;
    _currentPhone = phone;
    _currentPassword = password;

    // Update the stored password if user exists
    if (_users.containsKey(email)) {
      _users[email] = password;
    }

    // Update profile image path if provided
    if (profileImagePath != null) {
      _profileImagePath = profileImagePath;
    }

    if (kDebugMode) {
      print('User info updated: $fullName, $phone, Image: $_profileImagePath');
    }
  }
}

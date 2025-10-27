import 'package:flutter/foundation.dart';
import '../models/department.dart';

class AuthService {
  static final ValueNotifier<Department?> _authNotifier = ValueNotifier(null);
  static Department? _currentDepartment;

  static ValueNotifier<Department?> get authNotifier => _authNotifier;

  static Department? get currentDepartment => _currentDepartment;

  static bool get isAuthenticated => _currentDepartment != null;

  static void setCurrentDepartment(Department department) {
    _currentDepartment = department;
    _authNotifier.value = department;
  }

  static void logout() {
    _currentDepartment = null;
    _authNotifier.value = null;
  }
}

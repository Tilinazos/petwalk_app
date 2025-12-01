// core/services/session_service.dart
import 'package:flutter/foundation.dart';

class SessionService extends ChangeNotifier {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  String? _userName;

  String? get userName => _userName;
  bool get isLoggedIn => _userName != null && _userName!.isNotEmpty;

  void login(String name) {
    _userName = name.trim();
    notifyListeners();
  }

  void logout() {
    _userName = null;
    notifyListeners();
  }
}


import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  dynamic _subscription;
  bool _loading = false;
  bool _booted = false;
  String? _error;

  UserModel? get user => _user;
  dynamic get subscription => _subscription;
  bool get loading => _loading;
  bool get booted => _booted;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasActiveSubscription => _subscription != null;

  final _service = AuthService();

  Future<void> bootstrap() async {
    _user = await _service.currentUser();
    if (_user != null) {
      _subscription = await _service.currentSubscription();
    }
    _booted = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final r = await _service.login(email, password);
      _user = r.user;
      _subscription = r.subscription;
      return true;
    } catch (e) {
      _error = _humanError(e);
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    String? orgName,
    required String password,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final r = await _service.register(name: name, email: email, phone: phone, orgName: orgName, password: password);
      _user = r.user;
      _subscription = r.subscription;
      return true;
    } catch (e) {
      _error = _humanError(e);
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _subscription = null;
    notifyListeners();
  }

  Future<void> refreshSubscription() async {
    _subscription = await _service.currentSubscription();
    notifyListeners();
  }

  String _humanError(dynamic e) {
    final s = e.toString();
    if (s.contains('Invalid credentials')) return 'Wrong email or password';
    if (s.contains('Email already')) return 'Email already registered';
    if (s.contains('SocketException') || s.contains('Connection refused')) return 'Cannot reach server. Check internet/backend.';
    return s.length > 120 ? s.substring(0, 120) : s;
  }
}

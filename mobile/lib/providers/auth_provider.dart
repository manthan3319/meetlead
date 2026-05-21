import 'package:dio/dio.dart';
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
    if (e is DioException) {
      final t = e.type;
      if (t == DioExceptionType.connectionError ||
          t == DioExceptionType.connectionTimeout) {
        return 'Cannot reach server. Check internet/backend.';
      }
      final data = e.response?.data;
      String? msg;
      if (data is Map && data['message'] is String) {
        msg = data['message'] as String;
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      }
      msg ??= e.message;
      final status = e.response?.statusCode;
      if (msg != null && msg.isNotEmpty) {
        debugPrint('Auth error [$status]: $msg');
        return msg;
      }
      return status != null ? 'Request failed ($status)' : 'Network error';
    }
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Cannot reach server. Check internet/backend.';
    }
    return s.length > 160 ? s.substring(0, 160) : s;
  }
}

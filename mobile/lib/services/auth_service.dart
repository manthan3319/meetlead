import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final dynamic subscription;
  AuthResult(this.user, this.subscription);
}

class AuthService {
  final api = ApiService();

  Future<AuthResult> login(String email, String password) async {
    final r = await api.dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = r.data['token'];
    final user = UserModel.fromJson(r.data['user']);
    final sub = r.data['subscription'];
    await api.saveToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    return AuthResult(user, sub);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    String? phone,
    String? orgName,
    required String password,
  }) async {
    final r = await api.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (orgName != null && orgName.isNotEmpty) 'orgName': orgName,
      'password': password,
    });
    final token = r.data['token'];
    final user = UserModel.fromJson(r.data['user']);
    final sub = r.data['subscription'];
    await api.saveToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    return AuthResult(user, sub);
  }

  Future<UserModel?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.userKey);
    final token = await api.getToken();
    if (raw == null || token == null) return null;
    try {
      final r = await api.dio.get('/auth/me');
      final fresh = UserModel.fromJson(r.data['user']);
      await prefs.setString(AppConstants.userKey, jsonEncode(fresh.toJson()));
      return fresh;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await api.clear();
        await prefs.remove(AppConstants.userKey);
        return null;
      }
      return UserModel.fromJson(jsonDecode(raw));
    }
  }

  Future<void> logout() async {
    await api.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
  }

  Future<dynamic> currentSubscription() async {
    try {
      final r = await api.dio.get('/subscriptions/current');
      return r.data is Map ? r.data['data'] : null;
    } catch (_) {
      return null;
    }
  }
}

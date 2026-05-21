import 'package:flutter/widgets.dart';

class LoginProvider {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? v) =>
      v == null || !v.contains('@') ? 'Enter a valid email' : null;

  String? validatePassword(String? v) =>
      v == null || v.length < 6 ? 'Password must be 6+ characters' : null;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

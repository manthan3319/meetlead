import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool get obscure => _obscure;

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  String? validateEmail(String? v) =>
      v == null || !v.contains('@') ? 'Enter a valid email' : null;

  String? validatePassword(String? v) =>
      v == null || v.length < 6 ? 'Password must be 6+ characters' : null;

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      emailController.text.trim(),
      passwordController.text,
    );
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

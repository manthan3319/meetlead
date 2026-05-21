import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';

class SignupProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final orgController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool get obscure => _obscure;

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  String? validateName(String? v) =>
      v == null || v.trim().isEmpty ? 'Enter your name' : null;

  String? validateEmail(String? v) =>
      v == null || !v.contains('@') ? 'Enter a valid email' : null;

  String? validatePhone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your phone number';
    if (s.length != 10) return 'Phone number must be exactly 10 digits';
    return null;
  }

  String? validatePassword(String? v) =>
      v == null || v.length < 6 ? 'Password must be 6+ characters' : null;

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      orgName: orgController.text.trim(),
      password: passwordController.text,
    );
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Signup failed'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    orgController.dispose();
    super.dispose();
  }
}

class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final buffer = StringBuffer();
    bool capitalizeNext = true;
    for (final ch in text.split('')) {
      if (ch == ' ') {
        buffer.write(ch);
        capitalizeNext = true;
      } else {
        buffer.write(capitalizeNext ? ch.toUpperCase() : ch.toLowerCase());
        capitalizeNext = false;
      }
    }
    final formatted = buffer.toString();
    if (formatted == text) return newValue;
    return TextEditingValue(
      text: formatted,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

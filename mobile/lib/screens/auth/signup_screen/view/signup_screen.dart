// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _org = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _org.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      orgName: _org.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const _AuthHero(
                    title: 'Create account',
                    subtitle: 'Start your 7-day free trial. No card required.',
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.light,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      size: 14, color: AppColors.dark),
                                  SizedBox(width: 4),
                                  Text(
                                    '7-day free trial',
                                    style: TextStyle(
                                      color: AppColors.dark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fill in the details to get started',
                          style: TextStyle(
                            color: AppColors.textgrey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _label('Full name'),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [_CapitalizeWordsFormatter()],
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textgrey, size: 20),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _label('Business / Workspace name'),
                        TextFormField(
                          controller: _org,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your business name',
                            prefixIcon: Icon(Icons.business_outlined,
                                color: AppColors.textgrey, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _label('Email'),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textgrey, size: 20),
                          ),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _label('Phone'),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter your phone number',
                            prefixIcon: Icon(Icons.phone_outlined,
                                color: AppColors.textgrey, size: 20),
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Enter your phone number';
                            if (s.length != 10) {
                              return 'Phone number must be exactly 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _label('Password'),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textgrey, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textgrey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => v == null || v.length < 6
                              ? 'Password must be 6+ characters'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _submit,
                            child: auth.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _LegalText(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: AppColors.textgrey,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => Navigator.maybePop(context),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _CapitalizeWordsFormatter extends TextInputFormatter {
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

class _LegalText extends StatelessWidget {
  const _LegalText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By creating an account you agree to our ',
        style: const TextStyle(color: AppColors.textgrey, fontSize: 11.5),
        children: [
          TextSpan(
            text: 'Terms',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 60),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.dark],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MeetLead Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path()
      ..lineTo(0, s.height - 30)
      ..quadraticBezierTo(s.width / 2, s.height + 20, s.width, s.height - 30)
      ..lineTo(s.width, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

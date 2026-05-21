import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';
import '../../signup_screen/view/signup_screen.dart';
import '../provider/login_provider.dart';
import '../widget/auth_hero.dart';
import '../widget/field_label.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LoginProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const AuthHero(
                      title: 'Welcome back',
                      subtitle: 'Sign in to your MeetLead Pro account',
                    ),
                    Expanded(
                      child: Padding(
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
                            key: p.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enter your credentials to continue',
                                  style: TextStyle(
                                    color: AppColors.textgrey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const FieldLabel('Email'),
                                TextFormField(
                                  controller: p.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textgrey,
                                      size: 20,
                                    ),
                                  ),
                                  validator: p.validateEmail,
                                ),
                                const SizedBox(height: 14),
                                const FieldLabel('Password'),
                                TextFormField(
                                  controller: p.passwordController,
                                  obscureText: p.obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => p.submit(context),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textgrey,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        p.obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textgrey,
                                        size: 20,
                                      ),
                                      onPressed: p.toggleObscure,
                                    ),
                                  ),
                                  validator: p.validatePassword,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Contact your admin to reset your password'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: auth.loading
                                        ? null
                                        : () => p.submit(context),
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
                                                'Sign In',
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
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textgrey
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: AppColors.textgrey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textgrey
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        color: AppColors.textgrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignupScreen()),
                                      ),
                                      child: const Text(
                                        'Sign up',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

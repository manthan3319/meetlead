import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';
import '../provider/signup_provider.dart';
import '../widget/auth_hero.dart';
import '../widget/field_label.dart';
import '../widget/legal_text.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatelessWidget {
  const _SignupView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SignupProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const AuthHero(
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
                    key: p.formKey,
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
                        const FieldLabel('Full name'),
                        TextFormField(
                          controller: p.nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [CapitalizeWordsFormatter()],
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textgrey, size: 20),
                          ),
                          validator: p.validateName,
                        ),
                        const SizedBox(height: 14),
                        const FieldLabel('Business / Workspace name'),
                        TextFormField(
                          controller: p.orgController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your business name',
                            prefixIcon: Icon(Icons.business_outlined,
                                color: AppColors.textgrey, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const FieldLabel('Email'),
                        TextFormField(
                          controller: p.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textgrey, size: 20),
                          ),
                          validator: p.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        const FieldLabel('Phone'),
                        TextFormField(
                          controller: p.phoneController,
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
                          validator: p.validatePhone,
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
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textgrey, size: 20),
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
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                auth.loading ? null : () => p.submit(context),
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
                        const LegalText(),
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
}

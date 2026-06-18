import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/auth/password_recovery/cubit/forgot_password_cubit.dart';
import 'package:grad_project/patient/features/auth/password_recovery/models/forgot_password_model.dart';
import 'package:grad_project/patient/features/auth/reset_password/reset_password_page.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = ForgotPasswordCubit();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _cubit.setEmail(_emailController.text);
    final success = await _cubit.submitForgotPassword();
    if (!mounted) return;

    final state = _cubit.state;
    if (success && state.resetToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(resetToken: state.resetToken!),
        ),
      );
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordModel>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xffF1F7FF),
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Card(
                          color: Colors.white,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enter your email address. We will send you a reset token to create a new password.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Email',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !state.isLoading,
                                    onChanged: _cubit.setEmail,
                                    decoration: InputDecoration(
                                      hintText: 'your@email.com',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter email';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(v.trim())) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 44,
                                    child: state.isLoading
                                        ? const Center(
                                            child:
                                                CircularProgressIndicator(),
                                          )
                                        : CustomButton(
                                            color: AppColors.skyBlue,
                                            text: 'Send Reset Link',
                                            onPressed: _onSubmit,
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: TextButton(
                                      onPressed: state.isLoading
                                          ? null
                                          : () => Navigator.maybePop(context),
                                      child: const Text(
                                        'Back to Sign In',
                                        style: TextStyle(
                                          color: Color(0xFF2DA6FF),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// commit update
 
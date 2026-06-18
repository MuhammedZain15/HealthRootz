import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/auth/forgot_password/forgot_password_page.dart';
import 'package:grad_project/patient/features/auth/sign_in/cubit/sign_in_cubit.dart';
import 'package:grad_project/patient/features/auth/sign_in/models/sign_in_model.dart';
import 'package:grad_project/patient/features/auth/sign_up/sign_up_page.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

class SignInForm extends StatefulWidget {
  final SignInCubit cubit;
  final SignInModel state;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const SignInForm({
    super.key,
    required this.cubit,
    required this.state,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Email', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.state.isLoading,
            onChanged: widget.cubit.setEmail,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Text('Password', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            enabled: !widget.state.isLoading,
            onChanged: widget.cubit.setPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter password';
              if (v.length < 6) return 'Password too short';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.state.isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF2DA6FF), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: widget.state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    color: AppColors.skyBlue,
                    text: 'Sign In',
                    onPressed: () {
                      widget.cubit.setEmail(_emailController.text);
                      widget.cubit.setPassword(_passwordController.text);
                      widget.onSubmit();
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: widget.state.isLoading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Color(0xFF2DA6FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// commit update
 
// dart
import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/features/auth/widgets/custom_button.dart';
import 'package:grad_project/features/layout.dart';

import '../sign_in/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _medicalCtrl = TextEditingController();

  String? _role;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _loading = false);
      // On success navigate to sign in (adjust route as needed)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppLayout()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xffF1F7FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Fill in your information to get started',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        const Text(
                          'Full Name *',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction:  TextInputAction.next,
                          controller: _nameCtrl,
                          decoration: InputDecoration(

                            hintText: 'John Doe',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter full name'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Email
                        const Text('Email *', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction:  TextInputAction.next,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'your@email.com',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter email';
                            final email = v.trim();
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(email))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Age
                        const Text('Age *', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction:  TextInputAction.next,
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '25',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter age';
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0) return 'Enter a valid age';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password
                        const Text(
                          'Password *',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction:  TextInputAction.next,
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 6) return 'Password too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Role dropdown instead of confirm password
                        const Text('Role *', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(

                          value: _role,
                          items: const [
                            DropdownMenuItem(
                              value: 'patient',
                              child: Text('Patient'),
                            ),
                            DropdownMenuItem(
                              value: 'doctor',
                              child: Text('Doctor'),
                            ),
                          ],
                          decoration: InputDecoration(

                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (v) => setState(() => _role = v),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Select a role' : null,
                        ),
                        const SizedBox(height: 12),

                        // Medical details (optional)
                        const Text(
                          'Medical Details (Optional)',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction:  TextInputAction.done,
                          controller: _medicalCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Any relevant medical conditions or information...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          height: 44,
                          child: CustomButton(
                            color: AppColors.skyBlue,
                            text: "Create Account",
                            onPressed: _createAccount,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            ),
                            child: const Text(
                              'Already have an account? Sign In',
                              style: TextStyle(color: Color(0xFF2DA6FF)),
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
      ),
    );
  }
}

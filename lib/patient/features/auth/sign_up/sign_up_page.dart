// dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/doctor/doctor_layout.dart';
import 'package:grad_project/patient/layout/patient_layout.dart';
import '../sign_in/sign_in_page.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // Doctor specific fields
  final TextEditingController _specialtyCtrl = TextEditingController();
  final TextEditingController _licenseCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _specialtyCtrl.dispose();
    _licenseCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authCubit = context.read<AuthCubit>();
    final resultState = await authCubit.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: 'doctor',
      specialty: _specialtyCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (resultState.status == AuthStatus.authenticated) {
      if (authCubit.isDoctor) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorAppLayout()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppLayout()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultState.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.next,
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
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter email';
                            }
                            final email = v.trim();
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(email)) {
                              return 'Enter a valid email';
                            }
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
                          textInputAction: TextInputAction.next,
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

                        // Specialty
                        const Text('Specialty *', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _specialtyCtrl,
                          decoration: InputDecoration(
                            hintText: 'Neurology, Cardiology, etc.',
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
                              ? 'Enter specialty'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // License Number
                        const Text('License Number *', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _licenseCtrl,
                          decoration: InputDecoration(
                            hintText: 'LIC-123456',
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
                              ? 'Enter license number'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Phone
                        const Text('Phone Number', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+1 234 567 890',
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
                        ),
                        const SizedBox(height: 12),

                        // Address
                        const Text('Clinic Address', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: _addressCtrl,
                          decoration: InputDecoration(
                            hintText: '123 Medical Center, City',
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
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          height: 44,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
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

// commit update
 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/doctor/doctor_layout.dart';
import 'package:grad_project/patient/features/auth/sign_in/cubit/sign_in_cubit.dart';
import 'package:grad_project/patient/features/auth/sign_in/models/sign_in_model.dart';
import 'package:grad_project/patient/features/auth/sign_in/widgets/sign_in_form.dart';
import 'package:grad_project/patient/layout/patient_layout.dart';
import 'package:grad_project/shared/widgets/auth_card_scaffold.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final SignInCubit _signInCubit;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _signInCubit = SignInCubit(context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _signInCubit.close();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = await _signInCubit.submit();
    if (!mounted || authState == null) {
      if (_signInCubit.state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_signInCubit.state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final authCubit = context.read<AuthCubit>();
    if (authCubit.isDoctor) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DoctorAppLayout()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppLayout()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _signInCubit,
      child: BlocBuilder<SignInCubit, SignInModel>(
        builder: (context, state) {
          return AuthCardScaffold(
            title: 'Sign In',
            onBack: () => Navigator.maybePop(context),
            child: SignInForm(
              cubit: _signInCubit,
              state: state,
              formKey: _formKey,
              onSubmit: _onSignIn,
            ),
          );
        },
      ),
    );
  }
}

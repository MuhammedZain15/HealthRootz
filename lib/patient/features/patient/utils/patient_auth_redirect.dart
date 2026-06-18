import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/auth/sign_in/sign_in_page.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';

/// Redirects to sign-in when patient API errors look like auth failures.
class PatientAuthRedirect {
  static bool isAuthFailure(String message) {
    final lower = message.toLowerCase();
    return lower.contains('401') ||
        lower.contains('unauthorized') ||
        lower.contains('token') ||
        lower.contains('expired') ||
        lower.contains('not authenticated');
  }

  static Future<void> handlePatientError(
    BuildContext context,
    PatientState state,
  ) async {
    if (state is! PatientError) return;
    if (!isAuthFailure(state.message)) return;
    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (_) => false,
    );
  }
}

// commit update
 
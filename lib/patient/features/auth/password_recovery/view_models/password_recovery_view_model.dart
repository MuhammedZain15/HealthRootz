import 'package:grad_project/core/services/auth_service.dart';
import '../models/forgot_password_model.dart';
import '../models/reset_password_model.dart';

/// Business logic for forgot / reset password flows.
class PasswordRecoveryViewModel {
  final AuthService _authService = AuthService();

  String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateNewPassword(String password, String confirm) {
    if (password.isEmpty) return 'Enter a new password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (confirm.isEmpty) return 'Confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }

  Future<(ForgotPasswordModel, String?)> requestReset(
    ForgotPasswordModel current,
  ) async {
    final validation = validateEmail(current.email);
    if (validation != null) {
      return (current.copyWith(errorMessage: validation), validation);
    }

    try {
      final result = await _authService.forgotPassword(
        email: current.email.trim(),
      );

      if (result.success && result.data != null) {
        final token = result.data!.resetToken;
        if (token == null || token.isEmpty) {
          return (
            current.copyWith(
              isLoading: false,
              errorMessage:
                  'No reset token received. Check your email or try again.',
            ),
            'Missing reset token',
          );
        }

        return (
          current.copyWith(
            isLoading: false,
            resetToken: token,
            successMessage: result.data!.message,
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to send reset request',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }

  Future<(ResetPasswordModel, String?)> submitReset(
    ResetPasswordModel current,
  ) async {
    final validation = validateNewPassword(
      current.newPassword,
      current.confirmPassword,
    );
    if (validation != null) {
      return (current.copyWith(errorMessage: validation), validation);
    }

    try {
      final result = await _authService.resetPassword(
        resetToken: current.resetToken,
        newPassword: current.newPassword,
      );

      if (result.success) {
        return (
          current.copyWith(
            isLoading: false,
            isCompleted: true,
            successMessage:
                result.data ?? 'Password changed successfully',
            clearError: true,
          ),
          null,
        );
      }

      return (
        current.copyWith(
          isLoading: false,
          errorMessage: result.message ?? 'Failed to reset password',
        ),
        result.message,
      );
    } catch (e) {
      return (
        current.copyWith(
          isLoading: false,
          errorMessage: 'Error: ${e.toString()}',
        ),
        e.toString(),
      );
    }
  }
}

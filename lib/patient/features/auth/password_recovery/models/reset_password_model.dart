/// State for reset-password screen.
class ResetPasswordModel {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isCompleted;

  const ResetPasswordModel({
    required this.resetToken,
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isCompleted = false,
  });

  ResetPasswordModel copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isCompleted,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ResetPasswordModel(
      resetToken: resetToken,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// commit update
 
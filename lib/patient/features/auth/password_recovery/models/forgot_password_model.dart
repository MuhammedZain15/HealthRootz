/// State for forgot-password screen.
class ForgotPasswordModel {
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? resetToken;

  const ForgotPasswordModel({
    this.email = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.resetToken,
  });

  factory ForgotPasswordModel.initial() => const ForgotPasswordModel();

  ForgotPasswordModel copyWith({
    String? email,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? resetToken,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ForgotPasswordModel(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      resetToken: resetToken ?? this.resetToken,
    );
  }

  bool get canNavigateToReset =>
      resetToken != null && resetToken!.isNotEmpty;
}

// commit update
 
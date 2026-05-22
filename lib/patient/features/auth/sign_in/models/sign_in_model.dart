/// State for sign-in screen.
class SignInModel {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  const SignInModel({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  factory SignInModel.initial() => const SignInModel();

  SignInModel copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

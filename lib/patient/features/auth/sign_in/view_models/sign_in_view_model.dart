import 'package:grad_project/core/cubit/auth_cubit.dart';
import '../models/sign_in_model.dart';

class SignInViewModel {
  String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'Enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Enter password';
    if (password.length < 6) return 'Password too short';
    return null;
  }

  String? validateForm(SignInModel model) {
    return validateEmail(model.email) ?? validatePassword(model.password);
  }

  Future<(AuthState, String?)> login(AuthCubit authCubit, SignInModel model) async {
    final error = validateForm(model);
    if (error != null) return (authCubit.state, error);

    final result = await authCubit.login(
      email: model.email.trim(),
      password: model.password,
    );

    if (result.status == AuthStatus.authenticated) {
      return (result, null);
    }
    return (result, result.errorMessage ?? 'Login failed');
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import '../models/sign_in_model.dart';

class SignInCubit extends Cubit<SignInModel> {
  final AuthCubit _authCubit;

  SignInCubit(this._authCubit) : super(SignInModel.initial());

  void setEmail(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }
  void setPassword(String value) =>
      emit(state.copyWith(password: value, clearError: true));

  Future<AuthState?> submit() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final error = _validateForm(state);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return null;
    }

    final authState = await _authCubit.login(
      email: state.email.trim(),
      password: state.password,
    );

    final loginError = authState.status == AuthStatus.authenticated
        ? null
        : authState.errorMessage ?? 'Login failed';

    emit(state.copyWith(isLoading: false, errorMessage: loginError));

    return loginError == null ? authState : null;
  }

  String? _validateForm(SignInModel model) {
    final email = model.email.trim();
    if (email.isEmpty) return 'Enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    if (model.password.isEmpty) return 'Enter password';
    if (model.password.length < 6) return 'Password too short';
    return null;
  }
}

// commit update
 
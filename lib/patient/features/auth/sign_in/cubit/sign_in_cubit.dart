import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import '../models/sign_in_model.dart';
import '../view_models/sign_in_view_model.dart';

class SignInCubit extends Cubit<SignInModel> {
  final AuthCubit _authCubit;
  final SignInViewModel _viewModel = SignInViewModel();

  SignInCubit(this._authCubit) : super(SignInModel.initial());

  void setEmail(String value) => emit(state.copyWith(email: value, clearError: true));
  void setPassword(String value) =>
      emit(state.copyWith(password: value, clearError: true));

  Future<AuthState?> submit() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final (authState, error) = await _viewModel.login(_authCubit, state);

    emit(state.copyWith(isLoading: false, errorMessage: error));

    return error == null ? authState : null;
  }
}

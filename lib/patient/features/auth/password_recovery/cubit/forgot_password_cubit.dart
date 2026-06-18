import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/forgot_password_model.dart';
import '../view_models/password_recovery_view_model.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordModel> {
  final PasswordRecoveryViewModel _viewModel = PasswordRecoveryViewModel();

  ForgotPasswordCubit() : super(ForgotPasswordModel.initial());

  void setEmail(String email) {
    emit(state.copyWith(email: email, clearError: true));
  }

  Future<bool> submitForgotPassword() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    final (updated, _) = await _viewModel.requestReset(state);
    emit(updated);

    return updated.canNavigateToReset;
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}

// commit update
 
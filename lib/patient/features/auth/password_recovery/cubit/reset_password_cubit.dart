import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/reset_password_model.dart';
import '../view_models/password_recovery_view_model.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordModel> {
  final PasswordRecoveryViewModel _viewModel = PasswordRecoveryViewModel();

  ResetPasswordCubit({required String resetToken})
      : super(ResetPasswordModel(resetToken: resetToken));

  void setNewPassword(String value) {
    emit(state.copyWith(newPassword: value, clearError: true));
  }

  void setConfirmPassword(String value) {
    emit(state.copyWith(confirmPassword: value, clearError: true));
  }

  Future<bool> submitReset() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    final (updated, _) = await _viewModel.submitReset(state);
    emit(updated);

    return updated.isCompleted;
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}

// commit update
 
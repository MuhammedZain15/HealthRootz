import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../network/token_storage.dart';
import '../services/auth_service.dart';

/// Holds the currently logged-in user and exposes auth actions.
///
/// Usage from any widget:
///   - Read user:  `context.read<AuthCubit>().state`
///   - Watch user: `context.watch<AuthCubit>().state`
///   - Login:      `context.read<AuthCubit>().login(email, password)`
///   - Logout:     `context.read<AuthCubit>().logout()`
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthState.initial());

  // ─── Login ─────────────────────────────────────────────────────────

  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.login(email: email, password: password);

    if (result.success && result.data != null) {
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
      );
      emit(newState);
      return newState;
    } else {
      final newState = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.message ?? 'Login failed',
      );
      emit(newState);
      return newState;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────

  Future<AuthState> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? specialty,
    String? licenseNumber,
    int? age,
    String? gender,
    String? medicalHistory,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
      address: address,
      specialty: specialty,
      licenseNumber: licenseNumber,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
    );

    if (result.success && result.data != null) {
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
      );
      emit(newState);
      return newState;
    } else {
      final newState = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.message ?? 'Registration failed',
      );
      emit(newState);
      return newState;
    }
  }

  // ─── Update Profile ────────────────────────────────────────────────

  Future<AuthState> updateProfile(Map<String, dynamic> updates) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.updateProfile(updates);

    if (result.success && result.data != null) {
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
      );
      emit(newState);
      return newState;
    } else {
      final newState = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.message ?? 'Profile update failed',
      );
      emit(newState);
      return newState;
    }
  }

  // ─── Try Auto-Login (check stored token) ──────────────────────────

  Future<void> tryAutoLogin() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.getProfile();

    if (result.success && result.data != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.data));
    } else {
      // Token expired or invalid — clear and go to login
      await TokenStorage.clearAll();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  // ─── Get Profile (Refresh) ────────────────────────────────────────

  Future<void> fetchProfile() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.getProfile();

    if (result.success && result.data != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.data));
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message ?? 'Failed to fetch profile',
        ),
      );
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthState.initial());
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  bool get isDoctor => state.user?.role == 'doctor';
  bool get isPatient => state.user?.role == 'patient';
  bool get isAuthenticated => state.status == AuthStatus.authenticated;
  UserModel? get user => state.user;
}

// ─── State ─────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

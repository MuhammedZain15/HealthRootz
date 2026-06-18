/// Response from POST /api/auth/forgot-password.
class ForgotPasswordResult {
  final String? resetToken;
  final String message;

  const ForgotPasswordResult({
    this.resetToken,
    required this.message,
  });

  factory ForgotPasswordResult.fromResponse(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;
      return ForgotPasswordResult(
        resetToken: (data['resetToken'] ?? map['resetToken'])?.toString(),
        message: (data['message'] ?? map['message'] ?? 'Reset link sent')
            .toString(),
      );
    }
    return const ForgotPasswordResult(message: 'Reset link sent');
  }
}

// commit update
 
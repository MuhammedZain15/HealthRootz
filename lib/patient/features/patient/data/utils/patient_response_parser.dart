import 'package:flutter/foundation.dart';

/// Parses patient API envelopes where the payload may live under different keys.
class PatientResponseParser {
  PatientResponseParser._();

  static const _nestedKeys = [
    'data',
    'patient',
    'user',
    'result',
    'profile',
  ];

  /// Logs the full raw body before any parsing (debug builds only).
  static void logRawResponse(String endpoint, dynamic body) {
    if (!kDebugMode) return;
    debugPrint('=== RAW API RESPONSE [$endpoint] ===');
    debugPrint('$body');
    debugPrint('=== END RAW RESPONSE ===');
  }

  /// Resolves the map that contains patient fields from any supported envelope.
  static Map<String, dynamic>? extractPatientMap(dynamic body) {
    if (body == null) return null;

    if (body is Map) {
      final root = Map<String, dynamic>.from(body);

      if (_looksLikePatient(root)) {
        return root;
      }

      Map<String, dynamic>? injectPasswords(Map<String, dynamic> map) {
        if (root.containsKey('password')) map['password'] = root['password'];
        if (root.containsKey('generatedPassword')) map['generatedPassword'] = root['generatedPassword'];
        if (root.containsKey('autoPassword')) map['autoPassword'] = root['autoPassword'];
        return map;
      }

      for (final key in _nestedKeys) {
        final nested = root[key];
        final resolved = _mapIfPatient(nested);
        if (resolved != null) return injectPasswords(resolved);
      }

      // e.g. { "success": true, "data": null, "patient": { ... } }
      if (root['data'] == null) {
        for (final key in _nestedKeys.skip(1)) {
          final nested = root[key];
          final resolved = _mapIfPatient(nested);
          if (resolved != null) return injectPasswords(resolved);
        }
      }

      // Strip envelope metadata and use remaining root fields if present.
      final stripped = Map<String, dynamic>.from(root)
        ..remove('success')
        ..remove('message')
        ..remove('status')
        ..remove('data');
      if (_looksLikePatient(stripped)) {
        return injectPasswords(stripped);
      }

      return root;
    }

    return null;
  }

  static Map<String, dynamic>? _mapIfPatient(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    if (_looksLikePatient(map)) return map;
    return null;
  }

  static bool _looksLikePatient(Map<String, dynamic> map) {
    return map.containsKey('name') ||
        map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('email') ||
        map.containsKey('phone');
  }

  static bool hasMinimumPatientFields(Map<String, dynamic> map) {
    final id = (map['_id'] ?? map['id'] ?? '').toString().trim();
    final name = (map['name'] ?? '').toString().trim();
    final email = (map['email'] ?? '').toString().trim();
    return id.isNotEmpty || name.isNotEmpty || email.isNotEmpty;
  }
}

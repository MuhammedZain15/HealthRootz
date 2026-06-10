// lib/core/network/api_config.dart
/// Local backend connection settings for physical device / emulator testing.
///
/// - Use your PC's Wi‑Fi IPv4 address (run `ipconfig` on Windows, `ifconfig` on Mac/Linux).
/// - Phone and PC must be on the same Wi‑Fi network.
/// - Do not use `localhost` or `127.0.0.1` on a physical device.
class ApiConfig {
  ApiConfig._();

  /// Your machine's LAN IP (update when your network changes).
  static const String host = '192.168.137.42';

  /// Backend port (must match your server, e.g. 5000 or 8000).
  static const int port = 8000;

  /// API path prefix on the server.
  static const String apiPath = '/api';

  static String get baseUrl => 'http://$host:$port$apiPath';
}

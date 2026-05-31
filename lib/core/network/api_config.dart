// lib/core/network/api_config.dart
/// Local backend connection settings for a real phone on the same Wi-Fi network.
///
/// The phone cannot use localhost for your PC. Keep this host set to the
/// backend machine's LAN IPv4 address, and keep [port] in sync with server.js.
class ApiConfig {
  ApiConfig._();

  /// Backend machine LAN IP.
  static const String host = '192.168.1.13';

  /// Backend port. Must match PORT in the Node.js .env/server.js.
  static const int port = 5000;

  /// API path prefix on the server.
  static const String apiPath = '/api';

  static String get baseUrl => 'http://$host:$port$apiPath';
}

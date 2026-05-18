import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isOnline = false;
  String? _apiBaseUrl;
  Timer? _pingTimer;

  bool get isOnline => _isOnline;
  Stream<bool> get onStatusChanged => _controller.stream;

  void init({String? apiBaseUrl}) {
    _apiBaseUrl = apiBaseUrl;
    _connectivity.onConnectivityChanged.listen((results) {
      _checkServer();
    });
    _checkServer();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkServer());
  }

  Future<void> _checkServer() async {
    final hasNetwork = await _hasNetworkConnectivity();
    if (!hasNetwork) {
      _setOnline(false);
      return;
    }
    if (_apiBaseUrl == null) {
      _setOnline(true);
      return;
    }
    try {
      await http
          .get(Uri.parse('$_apiBaseUrl/api/login'))
          .timeout(const Duration(seconds: 5));
      _setOnline(true);
    } catch (_) {
      _setOnline(false);
    }
  }

  Future<bool> _hasNetworkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  void _setOnline(bool online) {
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  void dispose() {
    _pingTimer?.cancel();
    _controller.close();
  }
}

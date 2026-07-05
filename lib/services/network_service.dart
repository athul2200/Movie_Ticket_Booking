import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection();

  // Stream controller to emit connection status
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectionChange => _connectionChangeController.stream;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  /// Initialize continuous monitoring
  void initialize() {
    _internetSubscription = _internetConnection.onStatusChange.listen((InternetStatus status) {
      final isConnected = status == InternetStatus.connected;
      if (_hasConnection != isConnected) {
        _hasConnection = isConnected;
        _connectionChangeController.add(_hasConnection);
      }
    });
  }

  /// One-time real internet connection check (DNS lookup/ping)
  Future<bool> checkConnection() async {
    // First check local interface to fail fast if Wi-Fi/Data is completely off
    final List<ConnectivityResult> connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _hasConnection = false;
      return false;
    }

    // Then perform actual internet ping verification
    _hasConnection = await _internetConnection.hasInternetAccess;
    return _hasConnection;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _connectionChangeController.close();
  }
}

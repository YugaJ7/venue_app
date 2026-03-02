import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  static Stream<bool> get connectionStream => _connectionController.stream;
  static bool _isConnected = true;
  
  static bool get isConnected => _isConnected;
  
  static Future<void> initialize() async {
    // Check initial connectivity status
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _isConnected = result.any((result) => result != ConnectivityResult.none);
    _connectionController.add(_isConnected);
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = results.any((result) => result != ConnectivityResult.none);
      _connectionController.add(_isConnected);
    });
  }
  
  static void dispose() {
    _connectionController.close();
  }
}

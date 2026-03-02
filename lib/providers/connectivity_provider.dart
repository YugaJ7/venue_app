import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  ConnectivityProvider() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    await ConnectivityService.initialize();
    _isInitialized = true;
    
    ConnectivityService.connectionStream.listen((bool isConnected) {
      _isConnected = isConnected;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    ConnectivityService.dispose();
    super.dispose();
  }
}

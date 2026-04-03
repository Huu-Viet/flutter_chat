import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


enum NetworkConnectionType {
  wifi,
  mobile,
  ethernet,
  none,
}

class NetworkStatus {
  final bool isConnected;
  final NetworkConnectionType connectionType;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
  });

  bool get isMobile => connectionType == NetworkConnectionType.mobile;
  bool get isWiFi => connectionType == NetworkConnectionType.wifi;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkStatus &&
          isConnected == other.isConnected &&
          connectionType == other.connectionType;

  @override
  int get hashCode => isConnected.hashCode ^ connectionType.hashCode;
}

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  
  Stream<NetworkStatus> get networkStatusStream {
    return _connectivity.onConnectivityChanged.map(_mapConnectivityResult);
  }

  Future<NetworkStatus> getCurrentNetworkStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(results);
  }

  NetworkStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return const NetworkStatus(
        isConnected: false,
        connectionType: NetworkConnectionType.none,
      );
    }

    // Priority: WiFi > Ethernet > Mobile
    if (results.contains(ConnectivityResult.wifi)) {
      return const NetworkStatus(
        isConnected: true,
        connectionType: NetworkConnectionType.wifi,
      );
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return const NetworkStatus(
        isConnected: true,
        connectionType: NetworkConnectionType.ethernet,
      );
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return const NetworkStatus(
        isConnected: true,
        connectionType: NetworkConnectionType.mobile,
      );
    }

    return const NetworkStatus(
      isConnected: false,
      connectionType: NetworkConnectionType.none,
    );
  }
}

// Providers đơn giản
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return networkService.networkStatusStream;
});
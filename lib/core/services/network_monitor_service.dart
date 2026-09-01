// lib/core/services/network_monitor_service.dart

import '../models/network_snapshot.dart';
import 'platform_network_service.dart';

class NetworkMonitorService {
  static Future<void> start() {
    return PlatformNetworkService.startMonitoring();
  }

  static Future<void> stop() {
    return PlatformNetworkService.stopMonitoring();
  }

  static Future<NetworkSnapshot?> snapshot() {
    return PlatformNetworkService.getCurrentUsage();
  }
}
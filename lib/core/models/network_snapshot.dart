// lib/core/models/network_snapshot.dart

import 'app_network_usage.dart';

class NetworkSnapshot {
  final DateTime timestamp;
  final int totalRxBytes;
  final int totalTxBytes;
  final List<AppNetworkUsage> apps;

  const NetworkSnapshot({
    required this.timestamp,
    required this.totalRxBytes,
    required this.totalTxBytes,
    required this.apps,
  });

  int get totalBytes => totalRxBytes + totalTxBytes;

  factory NetworkSnapshot.fromMap(Map<dynamic, dynamic> map) {
    final rawApps = map['apps'];

    final apps = <AppNetworkUsage>[];

    if (rawApps is List) {
      for (final item in rawApps) {
        if (item is Map) {
          apps.add(AppNetworkUsage.fromMap(item));
        }
      }
    }

    return NetworkSnapshot(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      totalRxBytes: (map['totalRxBytes'] as num?)?.toInt() ?? 0,
      totalTxBytes: (map['totalTxBytes'] as num?)?.toInt() ?? 0,
      apps: apps,
    );
  }
}
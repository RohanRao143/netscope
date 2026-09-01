// lib/core/models/app_network_usage.dart

class AppNetworkUsage {
  final String packageName;
  final String appName;
  final int uid;
  final int rxBytes;
  final int txBytes;
  final String? iconBase64;

  const AppNetworkUsage({
    required this.packageName,
    required this.appName,
    required this.uid,
    required this.rxBytes,
    required this.txBytes,
    this.iconBase64,
  });

  int get totalBytes => rxBytes + txBytes;

  factory AppNetworkUsage.fromMap(Map<dynamic, dynamic> map) {
    return AppNetworkUsage(
      packageName: map['packageName']?.toString() ?? '',
      appName: map['appName']?.toString() ?? 'Unknown app',
      uid: (map['uid'] as num?)?.toInt() ?? -1,
      rxBytes: (map['rxBytes'] as num?)?.toInt() ?? 0,
      txBytes: (map['txBytes'] as num?)?.toInt() ?? 0,
      iconBase64: map['iconBase64']?.toString(),
    );
  }
}
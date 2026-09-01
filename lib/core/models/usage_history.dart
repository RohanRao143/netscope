// lib/core/models/usage_history.dart

class UsageHistory {
  final DateTime timestamp;
  final int rxBytes;
  final int txBytes;

  const UsageHistory({
    required this.timestamp,
    required this.rxBytes,
    required this.txBytes,
  });

  int get totalBytes => rxBytes + txBytes;
}
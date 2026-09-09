class UsageHistory {
  final DateTime timestamp;
  final int rxBytes;
  final int txBytes;
  final int foregroundBytes;
  final int backgroundBytes;

  const UsageHistory({
    required this.timestamp,
    required this.rxBytes,
    required this.txBytes,
    this.foregroundBytes = 0,
    this.backgroundBytes = 0,
  });

  int get totalBytes => rxBytes + txBytes;
}

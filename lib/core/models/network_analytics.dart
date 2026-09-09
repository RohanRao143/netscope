class NetworkAnalytics {
  final int wifiRx;
  final int wifiTx;
  final int mobileRx;
  final int mobileTx;
  final int foregroundRx;
  final int foregroundTx;
  final int backgroundRx;
  final int backgroundTx;

  const NetworkAnalytics({
    this.wifiRx = 0,
    this.wifiTx = 0,
    this.mobileRx = 0,
    this.mobileTx = 0,
    this.foregroundRx = 0,
    this.foregroundTx = 0,
    this.backgroundRx = 0,
    this.backgroundTx = 0,
  });

  int get wifiBytes => wifiRx + wifiTx;
  int get mobileBytes => mobileRx + mobileTx;
  int get foregroundBytes => foregroundRx + foregroundTx;
  int get backgroundBytes => backgroundRx + backgroundTx;

  factory NetworkAnalytics.fromMap(Map<dynamic, dynamic> m) => NetworkAnalytics(
    wifiRx: (m['wifiRx'] as num?)?.toInt() ?? 0,
    wifiTx: (m['wifiTx'] as num?)?.toInt() ?? 0,
    mobileRx: (m['mobileRx'] as num?)?.toInt() ?? 0,
    mobileTx: (m['mobileTx'] as num?)?.toInt() ?? 0,
    foregroundRx: (m['foregroundRx'] as num?)?.toInt() ?? 0,
    foregroundTx: (m['foregroundTx'] as num?)?.toInt() ?? 0,
    backgroundRx: (m['backgroundRx'] as num?)?.toInt() ?? 0,
    backgroundTx: (m['backgroundTx'] as num?)?.toInt() ?? 0,
  );
}

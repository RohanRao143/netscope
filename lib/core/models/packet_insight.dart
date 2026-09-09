class PacketInsight {
  final DateTime timestamp;
  final String protocol;
  final String direction;
  final String source;
  final String destination;
  final int bytes;
  final String summary;
  final String? host;

  const PacketInsight({
    required this.timestamp,
    required this.protocol,
    required this.direction,
    required this.source,
    required this.destination,
    required this.bytes,
    required this.summary,
    this.host,
  });

  factory PacketInsight.fromMap(Map<dynamic, dynamic> m) => PacketInsight(
    timestamp: DateTime.fromMillisecondsSinceEpoch((m['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
    protocol: m['protocol']?.toString() ?? 'Unknown',
    direction: m['direction']?.toString() ?? 'Unknown',
    source: m['source']?.toString() ?? '-',
    destination: m['destination']?.toString() ?? '-',
    bytes: (m['bytes'] as num?)?.toInt() ?? 0,
    summary: m['summary']?.toString() ?? 'Network packet observed.',
    host: m['host']?.toString(),
  );
}

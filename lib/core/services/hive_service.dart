import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/packet_insight.dart';
import '../models/usage_history.dart';

class HiveService {
  static const _history = 'usage_history_v2';
  static const _packets = 'packet_insights_v1';
  static const _settings = 'settings_v1';
  static const _apps = 'app_usage_v1';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_history);
    await Hive.openBox(_packets);
    await Hive.openBox(_settings);
    await Hive.openBox(_apps);
    await _compact();
  }

  static Box get historyBox => Hive.box(_history);
  static Box get packetBox => Hive.box(_packets);
  static Box get settingsBox => Hive.box(_settings);
  static Box get appBox => Hive.box(_apps);

  static Future<void> addHistory(UsageHistory item) async {
    // One sample per 5 minutes is enough for long-term analytics.
    final key = item.timestamp.millisecondsSinceEpoch ~/ (5 * 60 * 1000);
    await historyBox.put(key, {
      't': item.timestamp.millisecondsSinceEpoch,
      'r': item.rxBytes,
      'x': item.txBytes,
      'f': item.foregroundBytes,
      'b': item.backgroundBytes,
    });
  }

  static List<UsageHistory> history() {
    final list = historyBox.values.whereType<Map>().map((m) => UsageHistory(
      timestamp: DateTime.fromMillisecondsSinceEpoch((m['t'] as num).toInt()),
      rxBytes: (m['r'] as num).toInt(),
      txBytes: (m['x'] as num).toInt(),
      foregroundBytes: (m['f'] as num?)?.toInt() ?? 0,
      backgroundBytes: (m['b'] as num?)?.toInt() ?? 0,
    )).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  static Future<void> addPacket(PacketInsight p) async {
    final key = '${p.timestamp.millisecondsSinceEpoch}_${p.protocol}_${p.destination}';
    await packetBox.put(key, {
      't': p.timestamp.millisecondsSinceEpoch,
      'p': p.protocol,
      'd': p.direction,
      's': p.source,
      'x': p.destination,
      'n': p.bytes,
      'm': p.summary,
      'h': p.host,
    });
  }

  static List<PacketInsight> packets({DateTime? since, DateTime? until}) {
    final min = since?.millisecondsSinceEpoch ?? 0;
    final max = until?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
    final result = packetBox.values.whereType<Map>().map((m) => PacketInsight(
      timestamp: DateTime.fromMillisecondsSinceEpoch((m['t'] as num).toInt()),
      protocol: m['p']?.toString() ?? 'Unknown',
      direction: m['d']?.toString() ?? 'Unknown',
      source: m['s']?.toString() ?? '-',
      destination: m['x']?.toString() ?? '-',
      bytes: (m['n'] as num?)?.toInt() ?? 0,
      summary: m['m']?.toString() ?? 'Network packet observed.',
      host: m['h']?.toString(),
    )).where((p) => p.timestamp.millisecondsSinceEpoch >= min && p.timestamp.millisecondsSinceEpoch <= max).toList();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  static Future<void> setAutoStart(bool value) => settingsBox.put('auto_start', value);
  static bool get autoStart => settingsBox.get('auto_start', defaultValue: true) == true;

  static Future<void> clearHistory() async {
    await historyBox.clear();
    await packetBox.clear();
  }

  static Future<void> _compact() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 365));
    final oldHistory = historyBox.keys.where((k) {
      final m = historyBox.get(k);
      return m is Map && DateTime.fromMillisecondsSinceEpoch((m['t'] as num).toInt()).isBefore(cutoff);
    }).toList();
    if (oldHistory.isNotEmpty) await historyBox.deleteAll(oldHistory);

    // Keep packet-level metadata intentionally short-lived: detailed packets are expensive.
    final packetCutoff = DateTime.now().subtract(const Duration(days: 30));
    final oldPackets = packetBox.keys.where((k) {
      final m = packetBox.get(k);
      return m is Map && DateTime.fromMillisecondsSinceEpoch((m['t'] as num).toInt()).isBefore(packetCutoff);
    }).toList();
    if (oldPackets.isNotEmpty) await packetBox.deleteAll(oldPackets);
  }
}

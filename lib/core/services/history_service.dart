// lib/core/services/history_service.dart

import '../models/network_snapshot.dart';
import '../models/usage_history.dart';

class HistoryService {
  static final List<UsageHistory> _history = [];

  static void addSnapshot(NetworkSnapshot snapshot) {
    _history.add(
      UsageHistory(
        timestamp: snapshot.timestamp,
        rxBytes: snapshot.totalRxBytes,
        txBytes: snapshot.totalTxBytes,
      ),
    );

    if (_history.length > 500) {
      _history.removeAt(0);
    }
  }

  static List<UsageHistory> get history =>
      List.unmodifiable(_history.reversed.toList());

  static void clear() {
    _history.clear();
  }
}
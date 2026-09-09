import '../models/network_snapshot.dart';
import '../models/usage_history.dart';
import 'hive_service.dart';

class HistoryService {
  static Future<void> addSnapshot(NetworkSnapshot snapshot, {int foregroundBytes = 0, int backgroundBytes = 0}) async {
    await HiveService.addHistory(UsageHistory(
      timestamp: snapshot.timestamp,
      rxBytes: snapshot.totalRxBytes,
      txBytes: snapshot.totalTxBytes,
      foregroundBytes: foregroundBytes,
      backgroundBytes: backgroundBytes,
    ));
  }

  static List<UsageHistory> get history => HiveService.history();
  static Future<void> clear() => HiveService.clearHistory();
}

import 'dart:async';
import 'package:flutter/services.dart';
import '../models/app_network_usage.dart';
import '../models/network_analytics.dart';
import '../models/network_snapshot.dart';

class PlatformNetworkService {
  static const MethodChannel _methodChannel = MethodChannel('netscope/network');
  static const EventChannel _eventChannel = EventChannel('netscope/network_events');
  static Stream<NetworkSnapshot>? _stream;
  static Stream<Map<String,dynamic>>? _packetStream;

  static Future<bool> isSupported() async => await _methodChannel.invokeMethod<bool>('isSupported') ?? false;
  static Future<bool> hasUsageAccess() async => await _methodChannel.invokeMethod<bool>('hasUsageAccess') ?? false;
  static Future<void> requestUsageAccess() => _methodChannel.invokeMethod<void>('requestUsageAccess');
  static Future<void> startMonitoring() => _methodChannel.invokeMethod<void>('startMonitoring');
  static Future<void> stopMonitoring() => _methodChannel.invokeMethod<void>('stopMonitoring');
  static Future<void> setAutoStart(bool enabled) => _methodChannel.invokeMethod<void>('setAutoStart', {'enabled': enabled});
  static Future<bool> getAutoStart() async => await _methodChannel.invokeMethod<bool>('getAutoStart') ?? false;
  static Future<void> startPacketInspection() => _methodChannel.invokeMethod<void>('startPacketInspection');
  static Future<void> stopPacketInspection() => _methodChannel.invokeMethod<void>('stopPacketInspection');
  static Future<bool> isPacketInspectionActive() async => await _methodChannel.invokeMethod<bool>('isPacketInspectionActive') ?? false;

  static Future<List<AppNetworkUsage>> getAppUsage() async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>('getAppUsage');
    return (result ?? []).whereType<Map>().map(AppNetworkUsage.fromMap).toList();
  }

  static Future<NetworkSnapshot?> getCurrentUsage() async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getCurrentUsage');
    return result == null ? null : NetworkSnapshot.fromMap(result);
  }

  static Future<NetworkAnalytics> getAnalytics() async {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getAnalytics');
    return NetworkAnalytics.fromMap(result ?? {});
  }

  static Future<int> getUsageNotificationCount(String packageName, {int days = 30}) async => await _methodChannel.invokeMethod<int>('getUsageNotificationCount', {'packageName': packageName, 'days': days}) ?? 0;

  static Future<List<Map<String, dynamic>>> getHostStats() async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>('getHostStats');
    return (result ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAppUsageHistory(String packageName, String range) async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>('getAppUsageHistory', {'packageName': packageName, 'range': range});
    return (result ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  static Stream<NetworkSnapshot> get usageStream {
    _stream ??= _eventChannel.receiveBroadcastStream().where((e) => e is Map).map((e) => NetworkSnapshot.fromMap(Map<dynamic,dynamic>.from(e as Map)));
    return _stream!;
  }

  static Stream<Map<String,dynamic>> get packetStream {
    _packetStream ??= _packetEventChannel.receiveBroadcastStream().where((e) => e is Map).map((e) => Map<String,dynamic>.from(e as Map));
    return _packetStream!;
  }

  static const EventChannel _packetEventChannel = EventChannel('netscope/packet_events');

  static Future<void> openAppUsageSettings() async { await _methodChannel.invokeMethod<void>('openAppUsageSettings'); }
}

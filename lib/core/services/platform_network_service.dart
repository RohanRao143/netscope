// lib/core/services/platform_network_service.dart

import 'dart:async';

import 'package:flutter/services.dart';

import '../models/app_network_usage.dart';
import '../models/network_snapshot.dart';

class PlatformNetworkService {
  static const MethodChannel _methodChannel =
      MethodChannel('netscope/network');

  static const EventChannel _eventChannel =
      EventChannel('netscope/network_events');

  static Stream<NetworkSnapshot>? _stream;

  static Future<bool> isSupported() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasUsageAccess() async {
    try {
      return await _methodChannel.invokeMethod<bool>('hasUsageAccess') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestUsageAccess() async {
    await _methodChannel.invokeMethod<void>('requestUsageAccess');
  }

  static Future<void> startMonitoring() async {
    await _methodChannel.invokeMethod<void>('startMonitoring');
  }

  static Future<void> stopMonitoring() async {
    await _methodChannel.invokeMethod<void>('stopMonitoring');
  }

  static Future<List<AppNetworkUsage>> getAppUsage() async {
    try {
      final result =
          await _methodChannel.invokeMethod<List<dynamic>>('getAppUsage');

      if (result == null) {
        return [];
      }

      return result
          .whereType<Map>()
          .map(AppNetworkUsage.fromMap)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<NetworkSnapshot?> getCurrentUsage() async {
    try {
      final result = await _methodChannel
          .invokeMethod<Map<dynamic, dynamic>>('getCurrentUsage');

      if (result == null) {
        return null;
      }

      return NetworkSnapshot.fromMap(result);
    } catch (_) {
      return null;
    }
  }

  static Stream<NetworkSnapshot> get usageStream {
    _stream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .map(
          (event) => NetworkSnapshot.fromMap(
            Map<dynamic, dynamic>.from(event as Map),
          ),
        );

    return _stream!;
  }

  static Future<void> openAppUsageSettings() async {
    try {
      await _methodChannel.invokeMethod<void>('openAppUsageSettings');
    } catch (_) {}
  }
}
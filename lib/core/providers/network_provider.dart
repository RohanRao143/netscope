// lib/core/providers/network_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_network_usage.dart';
import '../models/network_snapshot.dart';
import '../models/network_analytics.dart';
import '../services/history_service.dart';
import '../services/platform_network_service.dart';
import '../services/hive_service.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkSnapshot? _snapshot;
  List<AppNetworkUsage> _apps = [];
  bool _supported = true;
  bool _usageAccess = false;
  bool _monitoring = false;
  bool _loading = false;
  String? _error;
  bool _autoStart = true;
  NetworkAnalytics? _analytics;
  List<Map<String, dynamic>> _hostStats = [];

  StreamSubscription<NetworkSnapshot>? _subscription;
  StreamSubscription<Map<String,dynamic>>? _packetSubscription;

  NetworkSnapshot? get snapshot => _snapshot;

  List<AppNetworkUsage> get apps => List.unmodifiable(_apps);

  bool get supported => _supported;

  bool get usageAccess => _usageAccess;

  bool get monitoring => _monitoring;

  bool get loading => _loading;

  String? get error => _error;
  bool get autoStart => _autoStart;
  NetworkAnalytics? get analytics => _analytics;
  List<Map<String,dynamic>> get hostStats => List.unmodifiable(_hostStats);

  int get totalRxBytes => _snapshot?.totalRxBytes ?? 0;

  int get totalTxBytes => _snapshot?.totalTxBytes ?? 0;

  int get totalBytes => totalRxBytes + totalTxBytes;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    _autoStart = HiveService.autoStart;
    _supported = await PlatformNetworkService.isSupported();
    _usageAccess = await PlatformNetworkService.hasUsageAccess();

    if (_supported && _usageAccess) {
      await refresh();
      await loadAnalytics();
      await loadHostStats();
      await startMonitoring();
      _listenForPackets();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final snapshot = await PlatformNetworkService.getCurrentUsage();

    if (snapshot != null) {
      _snapshot = snapshot;
      _apps = [...snapshot.apps]
        ..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));

      await HistoryService.addSnapshot(snapshot);
      notifyListeners();
    }
  }



  void _listenForPackets() {
    _packetSubscription ??= PlatformNetworkService.packetStream.listen((m) async {
      final host = m['host']?.toString();
      if (host != null && host.isNotEmpty) {
        _hostStats = await PlatformNetworkService.getHostStats();
      }
      notifyListeners();
    });
  }

  Future<void> startPacketInspection() async {
    await PlatformNetworkService.startPacketInspection();
    _listenForPackets();
  }

  Future<void> stopPacketInspection() => PlatformNetworkService.stopPacketInspection();

  Future<void> loadAnalytics() async {
    _analytics = await PlatformNetworkService.getAnalytics();
    notifyListeners();
  }

  Future<void> loadHostStats() async {
    _hostStats = await PlatformNetworkService.getHostStats();
    notifyListeners();
  }

  Future<void> setAutoStart(bool value) async {
    _autoStart = value;
    await HiveService.setAutoStart(value);
    await PlatformNetworkService.setAutoStart(value);
    notifyListeners();
  }

  Future<void> requestUsageAccess() async {
    await PlatformNetworkService.requestUsageAccess();
  }

  Future<void> checkUsageAccess() async {
    _usageAccess = await PlatformNetworkService.hasUsageAccess();

    if (_usageAccess) {
      await refresh();
      await startMonitoring();
    }

    notifyListeners();
  }

  Future<void> startMonitoring() async {
    if (!_usageAccess || _monitoring) {
      return;
    }

    await PlatformNetworkService.startMonitoring();

    _subscription ??= PlatformNetworkService.usageStream.listen(
      (snapshot) {
        _snapshot = snapshot;

        _apps = [...snapshot.apps]
          ..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));

        HistoryService.addSnapshot(snapshot);

        notifyListeners();
      },
      onError: (_) {
        _error = 'Unable to receive network usage updates.';
        notifyListeners();
      },
    );

    _monitoring = true;
    notifyListeners();
  }

  Future<void> stopMonitoring() async {
    await PlatformNetworkService.stopMonitoring();

    await _subscription?.cancel();
    _subscription = null;

    _monitoring = false;

    notifyListeners();
  }

  Future<void> openUsageSettings() async {
    await PlatformNetworkService.openAppUsageSettings();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _packetSubscription?.cancel();
    super.dispose();
  }
}
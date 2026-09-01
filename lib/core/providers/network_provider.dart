// lib/core/providers/network_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_network_usage.dart';
import '../models/network_snapshot.dart';
import '../services/history_service.dart';
import '../services/platform_network_service.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkSnapshot? _snapshot;
  List<AppNetworkUsage> _apps = [];
  bool _supported = true;
  bool _usageAccess = false;
  bool _monitoring = false;
  bool _loading = false;
  String? _error;

  StreamSubscription<NetworkSnapshot>? _subscription;

  NetworkSnapshot? get snapshot => _snapshot;

  List<AppNetworkUsage> get apps => List.unmodifiable(_apps);

  bool get supported => _supported;

  bool get usageAccess => _usageAccess;

  bool get monitoring => _monitoring;

  bool get loading => _loading;

  String? get error => _error;

  int get totalRxBytes => _snapshot?.totalRxBytes ?? 0;

  int get totalTxBytes => _snapshot?.totalTxBytes ?? 0;

  int get totalBytes => totalRxBytes + totalTxBytes;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    _supported = await PlatformNetworkService.isSupported();
    _usageAccess = await PlatformNetworkService.hasUsageAccess();

    if (_supported && _usageAccess) {
      await refresh();
      await startMonitoring();
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

      HistoryService.addSnapshot(snapshot);
      notifyListeners();
    }
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
    super.dispose();
  }
}
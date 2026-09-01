// lib/core/services/app_lifecycle_service.dart

import 'package:flutter/widgets.dart';

import '../providers/network_provider.dart';

class AppLifecycleService
    with WidgetsBindingObserver {

  final NetworkProvider provider;

  AppLifecycleService(this.provider);

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      provider.checkUsageAccess();
    }
  }
}
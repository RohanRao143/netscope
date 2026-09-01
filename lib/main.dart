// lib/main.dart
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/providers/network_provider.dart';
import 'core/services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await AdService.initialize();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => NetworkProvider()..initialize(),
      child: const NetScopeApp(),
    ),
  );
}
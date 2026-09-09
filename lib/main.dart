import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/providers/network_provider.dart';
import 'core/services/ad_service.dart';
import 'core/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await AdService.initialize();
  }
  runApp(ChangeNotifierProvider(create: (_) => NetworkProvider()..initialize(), child: const NetScopeApp()));
}

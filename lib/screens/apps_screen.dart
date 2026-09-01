// lib/screens/apps_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/network_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_usage_tile.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, provider, _) {
        return AppScaffold(
          title: 'Applications',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.refresh,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.apps.length,
              itemBuilder: (context, index) {
                return AppUsageTile(
                  app: provider.apps[index],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
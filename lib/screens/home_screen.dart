// lib/screens/home_screen.dart
// Replace the previous HomeScreen with this version.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/network_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_usage_tile.dart';
import '../widgets/network_status_chip.dart';
import '../widgets/usage_card.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, provider, _) {
        return AppScaffold(
          title: 'NetScope',
          actions: [
            NetworkStatusChip(
              active: provider.monitoring,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.refresh,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                if (provider.supported &&
                    !provider.usageAccess)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.security_outlined,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Usage access required',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Allow NetScope to access Android '
                            'usage statistics to monitor data '
                            'usage by application.',
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed:
                                provider.openUsageSettings,
                            child: const Text(
                              'Grant access',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                UsageCard(
                  snapshot: provider.snapshot,
                ),
                const SizedBox(height: 20),
                Text(
                  'Top applications',
                  style:
                      Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...provider.apps.take(5).map(
                  (app) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailsScreen(app: app),
                        ),
                      );
                    },
                    child: AppUsageTile(app: app),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// lib/screens/details_screen.dart

import 'package:flutter/material.dart';

import '../core/models/app_network_usage.dart';
import '../core/services/format_service.dart';
import '../widgets/app_scaffold.dart';

class DetailsScreen extends StatelessWidget {
  final AppNetworkUsage app;

  const DetailsScreen({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: app.appName,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(
                      Icons.apps,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    app.appName,
                    style:
                        Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.packageName,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Downloaded'),
                  trailing: Text(
                    FormatService.bytes(app.rxBytes),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Uploaded'),
                  trailing: Text(
                    FormatService.bytes(app.txBytes),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.swap_vert),
                  title: const Text('Total'),
                  trailing: Text(
                    FormatService.bytes(app.totalBytes),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// lib/widgets/app_usage_tile.dart

import 'package:flutter/material.dart';

import '../core/models/app_network_usage.dart';
import '../core/services/format_service.dart';

class AppUsageTile extends StatelessWidget {
  final AppNetworkUsage app;

  const AppUsageTile({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            app.appName.isEmpty
                ? '?'
                : app.appName.substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(
          app.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          app.packageName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatService.bytes(app.totalBytes),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '↓ ${FormatService.bytes(app.rxBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '↑ ${FormatService.bytes(app.txBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
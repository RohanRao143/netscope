import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/services/format_service.dart';
import '../core/services/history_service.dart';
import 'history_detail_screen.dart';
import '../widgets/app_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = HistoryService.history;

    return AppScaffold(
      title: 'History',
      actions: [
        if (history.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear history',
            onPressed: () async {
              await HistoryService.clear();

              if (mounted) {
                setState(() {});
              }
            },
          ),
      ],
      body: history.isEmpty
          ? const Center(
              child: Text('No network history recorded yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailScreen(
                            timestamp: item.timestamp,
                          ),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      child: Icon(Icons.network_check),
                    ),
                    title: Text(
                      FormatService.bytes(item.totalBytes),
                    ),
                    subtitle: Text(
                      '↓ ${FormatService.bytes(item.rxBytes)}   '
                      '↑ ${FormatService.bytes(item.txBytes)}',
                    ),
                    trailing: Text(
                      DateFormat('HH:mm:ss').format(item.timestamp),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

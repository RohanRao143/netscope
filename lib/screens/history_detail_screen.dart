import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/models/packet_insight.dart';
import '../core/services/format_service.dart';
import '../core/services/hive_service.dart';
import '../widgets/app_scaffold.dart';

class HistoryDetailScreen extends StatelessWidget {
  final DateTime timestamp;

  const HistoryDetailScreen({
    super.key,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final packets = HiveService.packets(
      since: timestamp.subtract(const Duration(minutes: 5)),
      until: timestamp.add(const Duration(minutes: 5)),
    );

    final domains = <String, int>{};

    for (final packet in packets) {
      final host = packet.host;
      if (host != null && host.isNotEmpty) {
        domains[host] = (domains[host] ?? 0) + 1;
      }
    }

    return AppScaffold(
      title: 'Network details',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights),
              title: Text(
                DateFormat('dd MMM yyyy, HH:mm:ss').format(timestamp),
              ),
              subtitle: Text(
                'Packet observations: ${packets.length}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (packets.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No packet metadata was captured for this history interval. '
                  'Packet inspection must be enabled for detailed packet records.',
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this means',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_insight(packets, domains)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Observed traffic',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...packets.take(100).map(
              (packet) => Card(
                child: ListTile(
                  leading: Icon(
                    packet.protocol == 'DNS'
                        ? Icons.language
                        : Icons.swap_horiz,
                  ),
                  title: Text(
                    packet.host ?? packet.destination,
                  ),
                  subtitle: Text(
                    '${packet.protocol} • ${packet.direction} • '
                    '${FormatService.bytes(packet.bytes)}\n'
                    '${packet.summary}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    DateFormat('HH:mm').format(packet.timestamp),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _insight(
    List<PacketInsight> packets,
    Map<String, int> domains,
  ) {
    final dnsCount = packets.where((packet) => packet.protocol == 'DNS').length;
    final totalBytes = packets.fold<int>(
      0,
      (total, packet) => total + packet.bytes,
    );

    final topDomains = domains.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hostInsight = topDomains.isEmpty
        ? 'No domain names were available.'
        : 'The most frequently observed host was ${topDomains.first.key}.';

    return 'NetScope observed ${packets.length} packet records '
        '(${FormatService.bytes(totalBytes)} of metadata-accounted traffic). '
        '$dnsCount were DNS observations. '
        '$hostInsight '
        'Packet records are metadata, not message contents; '
        'encrypted application payloads remain unread.';
  }
}

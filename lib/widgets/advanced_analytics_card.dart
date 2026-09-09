import 'package:flutter/material.dart';

import '../core/models/network_analytics.dart';
import 'analytics_charts.dart';

class AdvancedAnalyticsCard extends StatelessWidget {
  final NetworkAnalytics? analytics;
  final List<Map<String, dynamic>> hosts;

  const AdvancedAnalyticsCard({
    super.key,
    required this.analytics,
    required this.hosts,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = this.analytics;

    return Column(
      children: [
        if (analytics != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced network analytics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  UsageSplitChart(
                    wifi: analytics.wifiBytes,
                    mobile: analytics.mobileBytes,
                    foreground: analytics.foregroundBytes,
                    background: analytics.backgroundBytes,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        _HostsCard(hosts: hosts),
      ],
    );
  }
}

class _HostsCard extends StatefulWidget {
  final List<Map<String, dynamic>> hosts;

  const _HostsCard({
    required this.hosts,
  });

  @override
  State<_HostsCard> createState() => _HostsCardState();
}

class _HostsCardState extends State<_HostsCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleHosts = widget.hosts.take(expanded ? 10 : 3).toList();

    return Card(
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: (value) {
          setState(() {
            expanded = value;
          });
        },
        title: const Text('Top network hosts'),
        subtitle: Text(
          widget.hosts.isEmpty
              ? 'Enable packet/DNS inspection to collect host frequency.'
              : 'Based on observed DNS frequency',
        ),
        children: visibleHosts.isEmpty
            ? const [
                ListTile(
                  title: Text('No host data captured yet.'),
                ),
              ]
            : visibleHosts.asMap().entries.map((entry) {
                final host = entry.value['host']?.toString() ?? 'Unknown host';
                final count = (entry.value['count'] as num?)?.toInt() ?? 0;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${entry.key + 1}'),
                  ),
                  title: Text(host),
                  trailing: Text('$count requests'),
                );
              }).toList(),
      ),
    );
  }
}

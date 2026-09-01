// lib/widgets/usage_card.dart

import 'package:flutter/material.dart';

import '../core/models/network_snapshot.dart';
import '../core/services/format_service.dart';

class UsageCard extends StatelessWidget {
  final NetworkSnapshot? snapshot;

  const UsageCard({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final rx = snapshot?.totalRxBytes ?? 0;
    final tx = snapshot?.totalTxBytes ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network usage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _UsageItem(
                    icon: Icons.download,
                    label: 'Downloaded',
                    value: FormatService.bytes(rx),
                  ),
                ),
                Expanded(
                  child: _UsageItem(
                    icon: Icons.upload,
                    label: 'Uploaded',
                    value: FormatService.bytes(tx),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              FormatService.bytes(rx + tx),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _UsageItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
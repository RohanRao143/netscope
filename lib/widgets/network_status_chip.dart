// lib/widgets/network_status_chip.dart

import 'package:flutter/material.dart';

class NetworkStatusChip extends StatelessWidget {
  final bool active;

  const NetworkStatusChip({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        active
            ? Icons.circle
            : Icons.circle_outlined,
        size: 12,
      ),
      label: Text(
        active
            ? 'Monitoring'
            : 'Stopped',
      ),
    );
  }
}
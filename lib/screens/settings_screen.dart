// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/network_provider.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, provider, _) {
        return AppScaffold(
          title: 'Settings',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('Live monitoring'),
                  subtitle: Text(
                    provider.monitoring
                        ? 'Network statistics are being monitored.'
                        : 'Monitoring is currently stopped.',
                  ),
                  value: provider.monitoring,
                  onChanged: provider.usageAccess
                      ? (value) async {
                          if (value) {
                            await provider.startMonitoring();
                          } else {
                            await provider.stopMonitoring();
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Usage access'),
                      subtitle: Text(
                        provider.usageAccess
                            ? 'Permission granted'
                            : 'Permission required',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: provider.openUsageSettings,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Refresh statistics'),
                      onTap: provider.refresh,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('NetScope'),
                  subtitle: Text('Local network usage monitor'),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Privacy\n\n'
                  'Network statistics are processed locally. '
                  'NetScope does not require a cloud backend.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
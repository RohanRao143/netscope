import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/network_provider.dart';
import '../core/services/platform_network_service.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool packetInspectionActive = false;

  @override
  void initState() {
    super.initState();

    PlatformNetworkService.isPacketInspectionActive().then((value) {
      if (mounted) {
        setState(() {
          packetInspectionActive = value;
        });
      }
    });
  }

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
                        : 'Monitoring is stopped.',
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
              Card(
                child: SwitchListTile(
                  title: const Text('Start monitoring after reboot'),
                  subtitle: const Text(
                    'Restarts network statistics monitoring after device boot.',
                  ),
                  value: provider.autoStart,
                  onChanged: provider.setAutoStart,
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('DNS / packet inspection'),
                  subtitle: const Text(
                    'Requires Android VPN consent. Captures DNS packet '
                    'metadata only; payload contents are not decrypted.',
                  ),
                  value: packetInspectionActive,
                  onChanged: (value) async {
                    if (value) {
                      await provider.startPacketInspection();
                    } else {
                      await provider.stopPacketInspection();
                    }

                    if (mounted) {
                      setState(() {
                        packetInspectionActive = value;
                      });
                    }
                  },
                ),
              ),
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
                      onTap: () async {
                        await provider.refresh();
                        await provider.loadAnalytics();
                        await provider.loadHostStats();
                      },
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
            ],
          ),
        );
      },
    );
  }
}

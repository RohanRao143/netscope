import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/network_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_usage_tile.dart';
import 'details_screen.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});
  @override Widget build(BuildContext context) => Consumer<NetworkProvider>(builder: (context, provider, _) {
    return AppScaffold(title: 'Applications', actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: provider.refresh)], body: RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(padding: const EdgeInsets.fromLTRB(16,16,16,100), itemCount: provider.apps.length, itemBuilder: (_, i) {
        final app = provider.apps[i];
        return InkWell(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(app: app))), child: AppUsageTile(app: app));
      }),
    ));
  });
}

import 'package:flutter/material.dart';
import '../core/models/app_network_usage.dart';
import '../core/services/format_service.dart';
import '../core/services/platform_network_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/analytics_charts.dart';

class DetailsScreen extends StatefulWidget {
  final AppNetworkUsage app;
  const DetailsScreen({super.key,required this.app});
  @override State<DetailsScreen> createState()=>_DetailsScreenState();
}
class _DetailsScreenState extends State<DetailsScreen> {
  String range='Daily';
  List<Map<String,dynamic>> points=[];
  int notificationCount=0;
  bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { setState(()=>loading=true); final p=await PlatformNetworkService.getAppUsageHistory(widget.app.packageName,range); final n=await PlatformNetworkService.getUsageNotificationCount(widget.app.packageName, days: range=='Monthly'?30:range=='Weekly'?7:1); if(!mounted)return; setState((){points=p; notificationCount=n;loading=false;}); }
  @override Widget build(BuildContext context)=>AppScaffold(title:widget.app.appName,body:ListView(padding:const EdgeInsets.fromLTRB(16,16,16,100),children:[
    Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[const CircleAvatar(radius:36,child:Icon(Icons.apps,size:36)),const SizedBox(height:12),Text(widget.app.appName,style:Theme.of(context).textTheme.headlineSmall),Text(widget.app.packageName)]))),
    const SizedBox(height:12),Card(child:Column(children:[ListTile(leading:const Icon(Icons.download),title:const Text('Downloaded'),trailing:Text(FormatService.bytes(widget.app.rxBytes))),const Divider(height:1),ListTile(leading:const Icon(Icons.upload),title:const Text('Uploaded'),trailing:Text(FormatService.bytes(widget.app.txBytes))),const Divider(height:1),ListTile(leading:const Icon(Icons.swap_vert),title:const Text('Total'),trailing:Text(FormatService.bytes(widget.app.totalBytes)))])),
    const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Usage analytics',style:Theme.of(context).textTheme.titleLarge),DropdownButton<String>(value:range,items:['Daily','Weekly','Monthly'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null){range=v;_load();}})]),const SizedBox(height:8),if(loading)const SizedBox(height:220,child:Center(child:CircularProgressIndicator())) else UsageLineChart(points:points)]))),
    const SizedBox(height:12),Card(child:ListTile(leading:const Icon(Icons.notifications_outlined),title:const Text('Usage notifications'),subtitle:const Text('Recorded notifications associated with this app usage period.'),trailing:Text('$notificationCount'))),
  ]));
}

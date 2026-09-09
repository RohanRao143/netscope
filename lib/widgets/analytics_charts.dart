import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/services/format_service.dart';

class UsageLineChart extends StatelessWidget
{
  final List<Map<String, dynamic>> points;
const UsageLineChart({super.key, required this.points});
  @override Widget build(BuildContext context) 
{
if (points.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('No usage data for this period.')));
    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) spots.add(FlSpot(i.toDouble(), ((points[i]['bytes'] as num?)?.toDouble() ?? 0)));
    final maxY = spots.map((e) => e.y).fold<double>(1, (a, b) => a > b ? a : b);
    return SizedBox(height: 240, child: LineChart(LineChartData(minY: 0, maxY: maxY * 1.15, gridData: const FlGridData(show: true), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, dotData: const FlDotData(show: false))])));
  }
}

class UsageSplitChart extends StatelessWidget
{
  final int wifi;
final int mobile;
final int foreground;
final int background;
const UsageSplitChart({super.key, required this.wifi, required this.mobile, required this.foreground, required this.background});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: SizedBox(height: 190, child: PieChart(PieChartData(centerSpaceRadius: 35, sectionsSpace: 2, sections: [PieChartSectionData(value: wifi.toDouble(), title: 'Wi-Fi', radius: 55), PieChartSectionData(value: mobile.toDouble(), title: 'Mobile', radius: 55)])))), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Wi-Fi  ${FormatService.bytes(wifi)}'), const SizedBox(height: 8), Text('Mobile  ${FormatService.bytes(mobile)}'), const SizedBox(height: 16), Text('Foreground  ${FormatService.bytes(foreground)}'), const SizedBox(height: 8), Text('Background  ${FormatService.bytes(background)}')]))]);
}

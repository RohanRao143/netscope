// lib/screens/about_screen.dart

import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'About',
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.network_check,
              size: 64,
            ),
            SizedBox(height: 20),
            Text(
              'NetScope',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Local network usage monitoring.',
            ),
            SizedBox(height: 24),
            Text(
              'Network statistics are collected locally '
              'using platform APIs. No cloud backend is required.',
            ),
          ],
        ),
      ),
    );
  }
}
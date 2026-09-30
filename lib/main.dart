import 'package:flutter/material.dart';

import 'package:path_finder/api/api_client.dart';
import 'package:path_finder/screens/home_screen.dart';
import 'package:path_finder/theme/app_theme.dart';

void main() => runApp(ShortestPathApp(api: ApiClient()));

class ShortestPathApp extends StatelessWidget {
  const new({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shortest path',
      theme: AppTheme.lightTheme,
      home: HomeScreen(api: api),
    );
  }
}

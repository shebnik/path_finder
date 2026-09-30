import 'package:flutter/material.dart';

import 'package:path_finder/models/task_result.dart';
import 'package:path_finder/screens/preview_screen.dart';

class ResultListScreen extends StatelessWidget {
  const new({required this.results, super.key});

  final List<TaskResult> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result list screen')),
      body: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            title: Text(
              result.path ?? 'No path found',
              textAlign: TextAlign.center,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PreviewScreen(result: result),
              ),
            ),
          );
        },
      ),
    );
  }
}

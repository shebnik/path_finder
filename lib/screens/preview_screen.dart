import 'package:flutter/material.dart';

import 'package:path_finder/models/grid_point.dart';
import 'package:path_finder/models/task_result.dart';
import 'package:path_finder/theme/app_theme.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({required this.result, super.key});

  final TaskResult result;

  @override
  Widget build(BuildContext context) {
    final grid = result.task.grid;
    final pathCells = {...?result.steps};

    return Scaffold(
      appBar: AppBar(title: const Text('Preview screen')),
      body: Column(
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: grid.width / grid.height,
              child: InteractiveViewer(
                maxScale: 20,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.width,
                  ),
                  itemCount: grid.width * grid.height,
                  itemBuilder: (context, index) {
                    // x = column, y = row.
                    final cell = GridPoint(
                      index % grid.width,
                      index ~/ grid.width,
                    );
                    return _buildCell(cell, pathCells);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              result.path ?? 'No path found',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(GridPoint cell, Set<GridPoint> pathCells) {
    final color = _colorOf(cell, pathCells);
    return DecoratedBox(
      decoration: BoxDecoration(color: color, border: Border.all(width: 0.5)),
      child: Center(
        child: FittedBox(
          child: Text(
            '$cell',
            style: TextStyle(
              color: color == AppTheme.blockedColor
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Color _colorOf(GridPoint cell, Set<GridPoint> pathCells) {
    final task = result.task;
    if (cell == task.start) return AppTheme.startColor;
    if (cell == task.end) return AppTheme.endColor;
    if (task.grid.isBlocked(cell)) return AppTheme.blockedColor;
    if (pathCells.contains(cell)) return AppTheme.pathColor;
    return AppTheme.emptyColor;
  }
}

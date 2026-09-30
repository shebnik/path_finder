import 'dart:collection';

import 'package:path_finder/models/grid.dart';
import 'package:path_finder/models/grid_point.dart';

class PathFinder {
  const new();

  static const List<(int dx, int dy)> _directions = [
    (0, -1), // up
    (1, 0), // right
    (0, 1), // down
    (-1, 0), // left
    (1, -1), // up-right
    (1, 1), // down-right
    (-1, 1), // down-left
    (-1, -1), // up-left
  ];

  List<GridPoint>? findPath(Grid grid, GridPoint start, GridPoint end) {
    if (!grid.isWalkable(start) || !grid.isWalkable(end)) return null;
    if (start == end) return [start];

    final cameFrom = <GridPoint, GridPoint?>{start: null};
    final queue = Queue<GridPoint>()..add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      for (final (dx, dy) in _directions) {
        final next = GridPoint(current.x + dx, current.y + dy);
        if (!grid.isWalkable(next) || cameFrom.containsKey(next)) continue;
        cameFrom[next] = current;

        if (next == end) return _reconstruct(cameFrom, end);
        queue.add(next);
      }
    }
    return null;
  }

  List<GridPoint> _reconstruct(
    Map<GridPoint, GridPoint?> cameFrom,
    GridPoint end,
  ) {
    final path = <GridPoint>[];
    for (GridPoint? cell = end; cell != null; cell = cameFrom[cell]) {
      path.add(cell);
    }
    return path.reversed.toList();
  }
}

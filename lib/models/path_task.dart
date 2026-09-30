import 'package:path_finder/models/grid.dart';
import 'package:path_finder/models/grid_point.dart';

class PathTask {
  const new({
    required this.id,
    required this.grid,
    required this.start,
    required this.end,
  });

  factory fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'field': final List<dynamic> field,
      'start': final Map<String, dynamic> startJson,
      'end': final Map<String, dynamic> endJson,
    }) {
      final grid = Grid.fromRows([
        for (final row in field)
          if (row is String)
            row
          else
            throw FormatException('Task $id: field rows must be strings'),
      ]);
      return PathTask(
        id: id,
        grid: grid,
        start: GridPoint.fromJson(startJson),
        end: GridPoint.fromJson(endJson),
      );
    }
    throw FormatException('Malformed task: $json');
  }

  final String id;
  final Grid grid;
  final GridPoint start;
  final GridPoint end;
}

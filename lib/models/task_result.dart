import 'package:path_finder/models/grid_point.dart';
import 'package:path_finder/models/path_task.dart';

class TaskResult {
  new({required this.task, required List<GridPoint>? steps})
    : steps = steps == null ? null : List.unmodifiable(steps);

  final PathTask task;

  final List<GridPoint>? steps;

  String get id => task.id;

  String? get path {
    final steps = this.steps;
    return steps == null ? null : formatPath(steps);
  }

  static String formatPath(Iterable<GridPoint> points) => points.join('->');

  Map<String, dynamic> toJson() => {
    'id': id,
    'result': {
      'steps': steps?.map((point) => point.toJson()).toList(),
      'path': path,
    },
  };
}

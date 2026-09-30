import 'package:path_finder/models/grid_point.dart';

class Grid {
  new _(this._rows);

  factory fromRows(List<String> rows) {
    if (rows.isEmpty || rows.first.isEmpty) {
      throw const FormatException('Grid must contain at least one cell');
    }
    final width = rows.first.length;
    for (final (y, row) in rows.indexed) {
      if (row.length != width) {
        throw FormatException(
          'Row $y has length ${row.length}, expected $width',
        );
      }
    }
    return Grid._(List.unmodifiable(rows));
  }

  static const _blockedCell = 'X';

  final List<String> _rows;

  int get width => _rows.first.length;
  int get height => _rows.length;

  bool contains(GridPoint point) =>
      point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;

  bool isBlocked(GridPoint point) => _rows[point.y][point.x] == _blockedCell;

  bool isWalkable(GridPoint point) => contains(point) && !isBlocked(point);
}

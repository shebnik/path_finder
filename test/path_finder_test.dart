import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/models/grid.dart';
import 'package:path_finder/models/grid_point.dart';
import 'package:path_finder/services/path_finder.dart';

void main() {
  const finder = PathFinder();

  test('finds a shortest path', () {
    final grid = Grid.fromRows(['....', '.XX.', '....']);

    expect(
      finder.findPath(grid, const GridPoint(0, 0), const GridPoint(3, 2)),
      [
        const GridPoint(0, 0),
        const GridPoint(1, 0),
        const GridPoint(2, 0),
        const GridPoint(3, 1),
        const GridPoint(3, 2),
      ],
    );
  });

  test('can move diagonally', () {
    final grid = Grid.fromRows(['....', '....', '....', '....']);

    expect(
      finder.findPath(grid, const GridPoint(0, 3), const GridPoint(3, 0)),
      [
        const GridPoint(0, 3),
        const GridPoint(1, 2),
        const GridPoint(2, 1),
        const GridPoint(3, 0),
      ],
    );
  });

  test('can move diagonally between blocked cells', () {
    final grid = Grid.fromRows(['.X', 'X.']);

    expect(
      finder.findPath(grid, const GridPoint(0, 0), const GridPoint(1, 1)),
      [const GridPoint(0, 0), const GridPoint(1, 1)],
    );
  });

  test('returns null when there is no path', () {
    final grid = Grid.fromRows(['...', 'XXX', '...']);

    expect(
      finder.findPath(grid, const GridPoint(0, 0), const GridPoint(2, 2)),
      isNull,
    );
  });
}

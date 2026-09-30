class GridPoint {
  const new(this.x, this.y);

  factory fromJson(Map<String, dynamic> json) =>
      GridPoint(_readInt(json, 'x'), _readInt(json, 'y'));

  final int x;
  final int y;

  Map<String, int> toJson() => {'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    throw FormatException('Expected a numeric "$key" coordinate, got: $value');
  }
}

import 'package:equatable/equatable.dart';

enum DrawingTool { pen, highlighter }

class DrawingPointEntity extends Equatable {
  final double x;
  final double y;

  const DrawingPointEntity({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

class DrawingStrokeEntity extends Equatable {
  final String id;
  final List<DrawingPointEntity> points;
  final String colorHex;
  final double strokeWidth;
  final DrawingTool tool;

  const DrawingStrokeEntity({
    required this.id,
    required this.points,
    required this.colorHex,
    required this.strokeWidth,
    required this.tool,
  });

  @override
  List<Object?> get props => [id, points, colorHex, strokeWidth, tool];
}

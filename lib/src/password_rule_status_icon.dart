import 'package:flutter/widgets.dart';

/// The state of one rule as the widget shows it.
enum PasswordRuleStatus {
  /// No text has been entered yet.
  neutral,

  /// The rule passes.
  passed,

  /// The rule fails.
  failed,
}

/// Paints the icon of one [PasswordRuleStatus] on the 24-unit grid Material
/// icons use, so it lines up with icon fonts without depending on one.
class _StatusIconPainter extends CustomPainter {
  const _StatusIconPainter({required this.status, required this.color});

  final PasswordRuleStatus status;
  final Color color;

  static const double _grid = 24;
  static const Offset _center = Offset(12, 12);
  static const double _ringRadius = 9;
  static const double _discRadius = 10;
  static const double _strokeWidth = 2;
  static const Offset _checkStart = Offset(7, 12);
  static const Offset _checkCorner = Offset(10.5, 15.5);
  static const Offset _checkEnd = Offset(17, 9);
  static const double _crossNear = 8.5;
  static const double _crossFar = 15.5;

  static Path _checkMark() => Path()
    ..moveTo(_checkStart.dx, _checkStart.dy)
    ..lineTo(_checkCorner.dx, _checkCorner.dy)
    ..lineTo(_checkEnd.dx, _checkEnd.dy);

  static Path _crossMark() => Path()
    ..moveTo(_crossNear, _crossNear)
    ..lineTo(_crossFar, _crossFar)
    ..moveTo(_crossFar, _crossNear)
    ..lineTo(_crossNear, _crossFar);

  /// Draws a filled disc and erases [mark] from it, so the background shows
  /// through the mark whatever its color.
  void _paintDisc(Canvas canvas, Path mark) {
    canvas
      ..saveLayer(Offset.zero & const Size.square(_grid), Paint())
      ..drawCircle(_center, _discRadius, Paint()..color = color)
      ..drawPath(
        mark,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.shortestSide / _grid);
    switch (status) {
      case PasswordRuleStatus.neutral:
        canvas.drawCircle(
          _center,
          _ringRadius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = _strokeWidth,
        );
      case PasswordRuleStatus.passed:
        _paintDisc(canvas, _checkMark());
      case PasswordRuleStatus.failed:
        _paintDisc(canvas, _crossMark());
    }
  }

  @override
  bool shouldRepaint(_StatusIconPainter oldDelegate) =>
      oldDelegate.status != status || oldDelegate.color != color;
}

/// The icon [FlutterPwValidator] draws next to a rule: a ring while the field
/// is empty, a disc with a check for a passing rule, and a disc with a cross
/// for a failing one.
///
/// It is drawn rather than taken from an icon font, so it needs neither
/// Material nor `uses-material-design`. Reuse it in an `itemBuilder` to keep
/// the default look in a custom row:
///
/// ```dart
/// itemBuilder: (context, item) => ListTile(
///   leading: PasswordRuleStatusIcon(status: item.status, color: color),
///   title: Text(item.label),
/// ),
/// ```
class PasswordRuleStatusIcon extends StatelessWidget {
  /// Creates the icon for [status] in [color], [size] logical pixels square.
  const PasswordRuleStatusIcon({
    super.key,
    required this.status,
    required this.color,
    this.size = 24,
  });

  /// Which of the three icons to draw.
  final PasswordRuleStatus status;

  /// The color of the ring or the disc.
  final Color color;

  /// The width and height of the icon.
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _StatusIconPainter(status: status, color: color),
  );
}

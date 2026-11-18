import 'package:flutter/widgets.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _iconColor = Color(0xFF123456);
const double _iconSize = 20;

Widget _harness(PasswordRuleStatus status) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: PasswordRuleStatusIcon(
      status: status,
      color: _iconColor,
      size: _iconSize,
    ),
  ),
);

bool _isSaveLayer(Symbol methodName, List<dynamic> arguments) =>
    methodName == #saveLayer;

/// Whether a `drawPath` call erases a mark made of [contours] strokes.
bool Function(Symbol, List<dynamic>) _erasesMark(int contours) =>
    (methodName, arguments) {
      if (methodName != #drawPath) {
        return false;
      }
      final path = arguments[0] as Path;
      final paint = arguments[1] as Paint;
      return paint.blendMode == BlendMode.clear &&
          path.computeMetrics().length == contours;
    };

void main() {
  group('PasswordRuleStatusIcon', () {
    testWidgets('should take the given size', (tester) async {
      await tester.pumpWidget(_harness(PasswordRuleStatus.neutral));

      expect(
        tester.getSize(find.byType(PasswordRuleStatusIcon)),
        const Size.square(_iconSize),
      );
    });

    testWidgets('should paint a ring for a neutral rule', (tester) async {
      await tester.pumpWidget(_harness(PasswordRuleStatus.neutral));

      expect(
        find.byType(PasswordRuleStatusIcon),
        paints..circle(color: _iconColor, style: PaintingStyle.stroke),
      );
      expect(
        find.byType(PasswordRuleStatusIcon),
        isNot(paints..something(_isSaveLayer)),
      );
    });

    testWidgets('should cut a check out of a disc for a passed rule', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(PasswordRuleStatus.passed));

      expect(
        find.byType(PasswordRuleStatusIcon),
        paints
          ..something(_isSaveLayer)
          ..circle(color: _iconColor, style: PaintingStyle.fill)
          ..something(_erasesMark(1))
          ..restore(),
      );
    });

    testWidgets('should cut a cross out of a disc for a failed rule', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(PasswordRuleStatus.failed));

      expect(
        find.byType(PasswordRuleStatusIcon),
        paints
          ..something(_isSaveLayer)
          ..circle(color: _iconColor, style: PaintingStyle.fill)
          ..something(_erasesMark(2))
          ..restore(),
      );
    });

    testWidgets('should repaint when the status changes', (tester) async {
      await tester.pumpWidget(_harness(PasswordRuleStatus.passed));

      await tester.pumpWidget(_harness(PasswordRuleStatus.failed));

      expect(
        find.byType(PasswordRuleStatusIcon),
        paints..something(_erasesMark(2)),
      );
    });
  });
}

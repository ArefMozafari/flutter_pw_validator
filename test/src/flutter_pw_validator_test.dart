import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _defaultColor = Color(0xFF111111);
const Color _successColor = Color(0xFF222222);
const Color _failureColor = Color(0xFF333333);
const Duration _halfAnimation = Duration(milliseconds: 100);

Widget _harness(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  home: Scaffold(body: child),
);

FlutterPwValidator _validator({
  required TextEditingController controller,
  PasswordRules rules = const PasswordRules(minLength: 8, digits: 1),
  Key? key,
  VoidCallback? onSuccess,
  VoidCallback? onFail,
  ValueChanged<PasswordValidation>? onChanged,
  FlutterPwValidatorStrings strings = const FlutterPwValidatorStrings(),
  bool showBar = true,
  bool showList = true,
  bool showStrengthLabel = false,
  Duration animationDuration = const Duration(milliseconds: 200),
  PasswordRuleItemBuilder? itemBuilder,
  PasswordBarBuilder? barBuilder,
  PasswordStrengthCalculator? strengthOf,
  List<Listenable> listenables = const [],
  PasswordBarStyle barStyle = PasswordBarStyle.segments,
  bool shakeOnInvalid = true,
}) => FlutterPwValidator(
  key: key,
  controller: controller,
  rules: rules,
  onSuccess: onSuccess,
  onFail: onFail,
  onChanged: onChanged,
  strings: strings,
  defaultColor: _defaultColor,
  successColor: _successColor,
  failureColor: _failureColor,
  showBar: showBar,
  showList: showList,
  showStrengthLabel: showStrengthLabel,
  animationDuration: animationDuration,
  itemBuilder: itemBuilder,
  barBuilder: barBuilder,
  strengthOf: strengthOf,
  listenables: listenables,
  barStyle: barStyle,
  shakeOnInvalid: shakeOnInvalid,
);

/// How far the rows are shifted sideways right now.
double _translationX(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .ancestor(of: find.text('1 digit'), matching: find.byType(Transform))
          .first,
    )
    .transform
    .getTranslation()
    .x;

/// The target colors of the bar segments, left to right.
List<Color?> _segmentColors(WidgetTester tester) => [
  for (final segment in tester.widgetList<AnimatedContainer>(
    find.byType(AnimatedContainer),
  ))
    (segment.decoration as BoxDecoration?)?.color,
];

/// The color [label] animates towards.
Color? _textColor(WidgetTester tester, String label) => tester
    .widget<AnimatedDefaultTextStyle>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedDefaultTextStyle),
          )
          .first,
    )
    .style
    .color;

/// The color [label] is drawn with right now.
Color? _renderedTextColor(WidgetTester tester, String label) => tester
    .widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    )
    .style
    .color;

String _persianDigits(int count) => '$count رقم';

bool _hasNoSpaces(String password) => !password.contains(' ');

PasswordStrength _alwaysStrong(
  String password,
  PasswordValidation validation,
) => PasswordStrength.strong;

Widget _describeItem(BuildContext context, PasswordRuleItem item) =>
    Text('${item.label} ${item.status.name}');

Widget _describeBar(BuildContext context, int passed, int total) =>
    Text('$passed/$total');

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());

  tearDown(() => controller.dispose());

  group('FlutterPwValidator', () {
    testWidgets('should render one row per active rule with its label', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('1 digit'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('should render one bar segment per active rule', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      expect(_segmentColors(tester), hasLength(2));
    });

    testWidgets('should use the default color while the text is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      expect(_segmentColors(tester), [_defaultColor, _defaultColor]);
      expect(_textColor(tester, 'At least 8 characters'), _defaultColor);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('should color each rule by its result once text exists', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'At least 8 characters'), _failureColor);
      expect(_textColor(tester, '1 digit'), _successColor);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      expect(_segmentColors(tester), [_successColor, _defaultColor]);
    });

    testWidgets('should return to the default color when the text is cleared', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));
      controller.text = 'abc1';
      await tester.pumpAndSettle();

      controller.text = '';
      await tester.pumpAndSettle();

      expect(_textColor(tester, '1 digit'), _defaultColor);
      expect(_segmentColors(tester), [_defaultColor, _defaultColor]);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    });

    testWidgets('should show a pre-filled controller as evaluated', (
      tester,
    ) async {
      controller.text = 'abcdefg1';

      await tester.pumpWidget(_harness(_validator(controller: controller)));

      expect(_segmentColors(tester), [_successColor, _successColor]);
    });

    testWidgets('should take colors and text style from the theme by default', (
      tester,
    ) async {
      const outline = Color(0xFF444444);
      const error = Color(0xFF555555);
      const fontSize = 23.0;
      final theme = ThemeData(
        colorScheme: const ColorScheme.light(outline: outline, error: error),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: fontSize)),
      );
      await tester.pumpWidget(
        _harness(
          FlutterPwValidator(
            controller: controller,
            rules: const PasswordRules(minLength: 8),
          ),
          theme: theme,
        ),
      );

      expect(_textColor(tester, 'At least 8 characters'), outline);
      expect(_renderedTextColor(tester, 'At least 8 characters'), outline);
      expect(
        tester
            .widget<AnimatedDefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('At least 8 characters'),
                    matching: find.byType(AnimatedDefaultTextStyle),
                  )
                  .first,
            )
            .style
            .fontSize,
        fontSize,
      );

      controller.text = 'a';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'At least 8 characters'), error);
    });

    testWidgets('should hide the bar when showBar is false', (tester) async {
      await tester.pumpWidget(
        _harness(_validator(controller: controller, showBar: false)),
      );

      expect(_segmentColors(tester), isEmpty);
      expect(find.text('1 digit'), findsOneWidget);
    });

    testWidgets('should hide the list when showList is false', (tester) async {
      await tester.pumpWidget(
        _harness(_validator(controller: controller, showList: false)),
      );

      expect(_segmentColors(tester), hasLength(2));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should relabel the rows when the strings change', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            strings: const FlutterPwValidatorStrings(digits: _persianDigits),
          ),
        ),
      );

      expect(find.text('1 رقم'), findsOneWidget);
      expect(find.text('1 digit'), findsNothing);
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('should re-evaluate when the rules change', (tester) async {
      controller.text = 'abc';
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            rules: const PasswordRules(letters: 3),
          ),
        ),
      );

      expect(find.text('3 letters'), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(1));
      expect(_segmentColors(tester), [_successColor]);
    });
  });

  group('FlutterPwValidator animation', () {
    testWidgets('should animate a row towards its new color', (tester) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      controller.text = 'abc1';
      await tester.pump();
      await tester.pump(_halfAnimation);

      final midway = _renderedTextColor(tester, '1 digit');
      expect(midway, isNot(_defaultColor));
      expect(midway, isNot(_successColor));

      await tester.pumpAndSettle();

      expect(_renderedTextColor(tester, '1 digit'), _successColor);
    });

    testWidgets('should not animate when animationDuration is zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          _validator(controller: controller, animationDuration: Duration.zero),
        ),
      );

      controller.text = 'abc1';
      await tester.pump();

      expect(_renderedTextColor(tester, '1 digit'), _successColor);
    });

    testWidgets('should not animate when the platform disables animations', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      controller.text = 'abc1';
      await tester.pump();

      expect(_renderedTextColor(tester, '1 digit'), _successColor);
    });
  });

  group('FlutterPwValidator strength label', () {
    testWidgets('should be hidden by default', (tester) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));
      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.text('Fair'), findsNothing);
    });

    testWidgets('should name the strength once text exists', (tester) async {
      await tester.pumpWidget(
        _harness(_validator(controller: controller, showStrengthLabel: true)),
      );

      expect(find.text('Weak'), findsNothing);

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.text('Fair'), findsOneWidget);
      expect(_textColor(tester, 'Fair'), _defaultColor);

      controller.text = 'abcdefg1';
      await tester.pumpAndSettle();

      expect(find.text('Strong'), findsOneWidget);
      expect(_textColor(tester, 'Strong'), _successColor);
    });

    testWidgets('should color a weak password with failureColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            rules: const PasswordRules(minLength: 8, digits: 1, special: 1),
            showStrengthLabel: true,
          ),
        ),
      );

      controller.text = 'a';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'Weak'), _failureColor);
    });
  });

  group('FlutterPwValidator builders', () {
    testWidgets('should build each row with itemBuilder', (tester) async {
      await tester.pumpWidget(
        _harness(
          _validator(controller: controller, itemBuilder: _describeItem),
        ),
      );

      expect(find.text('At least 8 characters neutral'), findsOneWidget);
      expect(find.text('1 digit neutral'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.text('At least 8 characters failed'), findsOneWidget);
      expect(find.text('1 digit passed'), findsOneWidget);
    });

    testWidgets('should pass the rule to itemBuilder', (tester) async {
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            rules: const PasswordRules(digits: 3),
            itemBuilder: (context, item) =>
                Text('${(item.rule as CountRule).count}'),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should build the bar with barBuilder', (tester) async {
      await tester.pumpWidget(
        _harness(_validator(controller: controller, barBuilder: _describeBar)),
      );

      expect(find.text('0/2'), findsOneWidget);
      expect(_segmentColors(tester), isEmpty);

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
    });
  });

  group('FlutterPwValidator custom rules', () {
    testWidgets('should render a custom rule with its label', (tester) async {
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            rules: const PasswordRules(
              custom: [CustomRule(label: 'No spaces', test: _hasNoSpaces)],
            ),
          ),
        ),
      );

      expect(find.text('No spaces'), findsOneWidget);

      controller.text = 'a b';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'No spaces'), _failureColor);
    });
  });

  group('FlutterPwValidator strengthOf', () {
    testWidgets('should label and color the strength it returns', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            showStrengthLabel: true,
            strengthOf: _alwaysStrong,
          ),
        ),
      );

      controller.text = 'a';
      await tester.pumpAndSettle();

      expect(find.text('Strong'), findsOneWidget);
      expect(_textColor(tester, 'Strong'), _successColor);
    });
  });

  group('FlutterPwValidator semantics', () {
    testWidgets('should announce each rule with whether it is met', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      expect(find.bySemanticsLabel('1 digit'), findsOneWidget);

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('1 digit, met'), findsOneWidget);
      expect(
        find.bySemanticsLabel('At least 8 characters, not met'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('should leave the semantics of a built row to the builder', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _harness(
          _validator(controller: controller, itemBuilder: _describeItem),
        ),
      );

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('1 digit passed'), findsOneWidget);
      expect(find.bySemanticsLabel('1 digit, met'), findsNothing);
      handle.dispose();
    });
  });

  group('FlutterPwValidator listenables', () {
    testWidgets('should re-evaluate when a listenable notifies', (
      tester,
    ) async {
      final confirm = TextEditingController();
      addTearDown(confirm.dispose);
      final validations = <PasswordValidation>[];
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            rules: PasswordRules(custom: [MatchRule(() => confirm.text)]),
            listenables: [confirm],
            onChanged: validations.add,
          ),
        ),
      );
      controller.text = 'secret';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'Passwords match'), _failureColor);

      confirm.text = 'secret';
      await tester.pumpAndSettle();

      expect(_textColor(tester, 'Passwords match'), _successColor);
      expect(validations.last.isValid, isTrue);
    });

    testWidgets('should stop listening to a removed listenable', (
      tester,
    ) async {
      final confirm = TextEditingController();
      addTearDown(confirm.dispose);
      var calls = 0;
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            listenables: [confirm],
            onChanged: (validation) => calls++,
          ),
        ),
      );

      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            onChanged: (validation) => calls++,
          ),
        ),
      );
      confirm.text = 'a';
      await tester.pumpAndSettle();

      expect(calls, 0);
    });
  });

  group('FlutterPwValidator continuous bar', () {
    testWidgets('should fill the share of passing rules', (tester) async {
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            barStyle: PasswordBarStyle.continuous,
          ),
        ),
      );

      expect(
        tester
            .widget<AnimatedFractionallySizedBox>(
              find.byType(AnimatedFractionallySizedBox),
            )
            .widthFactor,
        0,
      );

      controller.text = 'abc1';
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<AnimatedFractionallySizedBox>(
              find.byType(AnimatedFractionallySizedBox),
            )
            .widthFactor,
        0.5,
      );
      expect(_segmentColors(tester), [
        Color.lerp(_failureColor, _successColor, 0.5),
      ]);

      controller.text = 'abcdefg1';
      await tester.pumpAndSettle();

      expect(_segmentColors(tester), [_successColor]);
    });
  });

  group('FlutterPwValidator shake', () {
    testWidgets('should shake when validate() finds the password invalid', (
      tester,
    ) async {
      final key = GlobalKey<FlutterPwValidatorState>();
      await tester.pumpWidget(
        _harness(_validator(key: key, controller: controller)),
      );
      controller.text = 'a';
      await tester.pumpAndSettle();

      key.currentState!.validate();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(_translationX(tester), isNot(0));

      await tester.pumpAndSettle();

      expect(_translationX(tester), 0);
    });

    testWidgets('should not shake while typing', (tester) async {
      await tester.pumpWidget(_harness(_validator(controller: controller)));

      controller.text = 'a';
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(_translationX(tester), 0);
    });

    testWidgets('should not shake when shakeOnInvalid is false', (
      tester,
    ) async {
      final key = GlobalKey<FlutterPwValidatorState>();
      await tester.pumpWidget(
        _harness(
          _validator(key: key, controller: controller, shakeOnInvalid: false),
        ),
      );
      controller.text = 'a';
      await tester.pumpAndSettle();

      key.currentState!.validate();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(_translationX(tester), 0);
    });
  });

  group('FlutterPwValidator callbacks', () {
    testWidgets('should pass every evaluation to onChanged', (tester) async {
      final validations = <PasswordValidation>[];
      await tester.pumpWidget(
        _harness(
          _validator(controller: controller, onChanged: validations.add),
        ),
      );

      expect(validations, isEmpty);

      controller.text = 'abc';
      await tester.pumpAndSettle();
      controller.text = 'abcdefg1';
      await tester.pumpAndSettle();

      expect(validations.map((validation) => validation.isValid), [
        false,
        true,
      ]);
      expect(validations.last.strength, PasswordStrength.strong);
    });

    testWidgets(
      'should fire onSuccess when a change leaves the password valid',
      (tester) async {
        var successes = 0;
        var failures = 0;
        await tester.pumpWidget(
          _harness(
            _validator(
              controller: controller,
              onSuccess: () => successes++,
              onFail: () => failures++,
            ),
          ),
        );

        controller.text = 'abcdefg1';
        await tester.pumpAndSettle();

        expect(successes, 1);
        expect(failures, 0);
      },
    );

    testWidgets('should fire onFail on every change that leaves it invalid', (
      tester,
    ) async {
      var successes = 0;
      var failures = 0;
      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            onSuccess: () => successes++,
            onFail: () => failures++,
          ),
        ),
      );

      controller.text = 'a';
      await tester.pumpAndSettle();
      controller.text = 'ab';
      await tester.pumpAndSettle();

      expect(successes, 0);
      expect(failures, 2);
    });

    testWidgets('should not fire on first build with a pre-filled controller', (
      tester,
    ) async {
      var calls = 0;
      controller.text = 'abcdefg1';

      await tester.pumpWidget(
        _harness(
          _validator(
            controller: controller,
            onSuccess: () => calls++,
            onFail: () => calls++,
          ),
        ),
      );

      expect(calls, 0);
    });

    testWidgets('should stop listening once disposed', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _harness(_validator(controller: controller, onFail: () => calls++)),
      );

      await tester.pumpWidget(_harness(const SizedBox()));
      controller.text = 'a';
      await tester.pumpAndSettle();

      expect(calls, 0);
    });

    testWidgets('should follow a swapped controller', (tester) async {
      var calls = 0;
      final replacement = TextEditingController();
      addTearDown(replacement.dispose);
      await tester.pumpWidget(
        _harness(_validator(controller: controller, onFail: () => calls++)),
      );

      await tester.pumpWidget(
        _harness(_validator(controller: replacement, onFail: () => calls++)),
      );
      controller.text = 'a';
      await tester.pumpAndSettle();

      expect(calls, 0);

      replacement.text = 'b';
      await tester.pumpAndSettle();

      expect(calls, 1);
    });
  });

  group('FlutterPwValidatorState.validate', () {
    testWidgets('should re-evaluate, fire the callback and return the result', (
      tester,
    ) async {
      var successes = 0;
      final key = GlobalKey<FlutterPwValidatorState>();
      await tester.pumpWidget(
        _harness(
          _validator(
            key: key,
            controller: controller,
            onSuccess: () => successes++,
          ),
        ),
      );
      controller.text = 'abcdefg1';
      await tester.pumpAndSettle();

      final isValid = key.currentState!.validate();

      expect(isValid, isTrue);
      expect(successes, 2);
    });
  });
}

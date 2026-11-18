import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:password_rules/password_rules.dart';

import 'password_rule_status_icon.dart';

/// The labels the widget shows; the name 1.x users know for
/// [PasswordRuleStrings].
typedef FlutterPwValidatorStrings = PasswordRuleStrings;

/// The success color of 1.x, kept as the default so existing apps look the
/// same after upgrading.
const Color _successGreen = Color(0xFF2EE292);

/// The failure color of 1.x, the default since the widget stopped reading a
/// Material color scheme.
const Color _failureRed = Color(0xFFF9433E);

/// The neutral color of 1.x, used when the surrounding text style has no
/// color to derive one from.
const Color _neutralGray = Color(0xFFD3D3D3);

/// How much of the text color's opacity the neutral color keeps.
const double _neutralOpacity = 0.6;

/// Vertical gap between two rule rows.
const double _rowSpacing = 4;

/// Vertical gap between the strength label and the bar.
const double _labelSpacing = 4;

/// Horizontal gap between the icon and the label of a rule row.
const double _iconGap = 8;

/// Horizontal gap between two bar segments.
const double _segmentSpacing = 4;

/// Icon size relative to the label's font size.
const double _iconScale = 1.25;

/// Font size assumed when the text style has none.
const double _fallbackFontSize = 14;

/// How long the shake after an invalid [FlutterPwValidatorState.validate]
/// lasts.
const Duration _shakeDuration = Duration(milliseconds: 400);

/// How far the shake moves the widget sideways, in logical pixels.
const double _shakeAmplitude = 6;

/// How many times the shake swings left and right.
const double _shakeCycles = 3;

/// The sideways offset of the shake at [progress], from 0 to 1, decaying to
/// zero at the end.
double _shakeOffset(double progress) =>
    sin(progress * 2 * pi * _shakeCycles) * _shakeAmplitude * (1 - progress);

/// How the bar draws progress.
enum PasswordBarStyle {
  /// One segment per active rule, filled from the left.
  segments,

  /// One track whose fill grows with the share of passing rules and shifts
  /// from the failure color to the success color.
  continuous,
}

/// Builds the row of one rule in place of the default icon and label.
typedef PasswordRuleItemBuilder =
    Widget Function(BuildContext context, PasswordRuleItem item);

/// Builds the bar in place of the default segments, from the number of
/// passing rules and the number of active rules.
typedef PasswordBarBuilder =
    Widget Function(BuildContext context, int passed, int total);

/// Rates a password in place of [PasswordValidation.strength], for example
/// with an entropy estimator.
typedef PasswordStrengthCalculator =
    PasswordStrength Function(String password, PasswordValidation validation);

/// Everything a [PasswordRuleItemBuilder] needs to draw one rule.
class PasswordRuleItem {
  /// Creates the description of one rule row.
  const PasswordRuleItem({
    required this.rule,
    required this.label,
    required this.status,
  });

  /// The rule; a [CountRule] carries its count.
  final PasswordRule rule;

  /// The label from [FlutterPwValidator.strings].
  final String label;

  /// Whether the rule is neutral, passing or failing.
  final PasswordRuleStatus status;
}

/// A row of equal segments; the first [passed] are filled with [successColor].
class _ValidationBar extends StatelessWidget {
  const _ValidationBar({
    required this.passed,
    required this.total,
    required this.thickness,
    required this.successColor,
    required this.defaultColor,
    required this.duration,
  });

  final int passed;
  final int total;
  final double thickness;
  final Color successColor;
  final Color defaultColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) => Row(
    spacing: _segmentSpacing,
    children: [
      for (var index = 0; index < total; index++)
        Expanded(
          child: AnimatedContainer(
            duration: duration,
            height: thickness,
            decoration: BoxDecoration(
              color: index < passed ? successColor : defaultColor,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
        ),
    ],
  );
}

/// One track filled to [fraction] of its width in [fillColor].
class _ContinuousBar extends StatelessWidget {
  const _ContinuousBar({
    required this.fraction,
    required this.thickness,
    required this.fillColor,
    required this.trackColor,
    required this.duration,
  });

  final double fraction;
  final double thickness;
  final Color fillColor;
  final Color trackColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: thickness,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(thickness),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedFractionallySizedBox(
          duration: duration,
          widthFactor: fraction,
          heightFactor: 1,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
        ),
      ),
    ),
  );
}

/// One rule: an icon and its label, both in [color], read by screen readers
/// as [semanticsLabel]. Without an [icon] it draws [PasswordRuleStatusIcon].
class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.status,
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.color,
    required this.textStyle,
    required this.duration,
  });

  final PasswordRuleStatus status;
  final IconData? icon;
  final String label;
  final String semanticsLabel;
  final Color color;
  final TextStyle textStyle;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final iconSize = (textStyle.fontSize ?? _fallbackFontSize) * _iconScale;
    final key = ValueKey<(PasswordRuleStatus, IconData?, Color)>((
      status,
      icon,
      color,
    ));
    // Each rule is its own node, so a screen reader steps through the rules
    // one by one even when no ancestor splits its children apart.
    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        spacing: _iconGap,
        children: [
          AnimatedSwitcher(
            duration: duration,
            child: switch (icon) {
              null => PasswordRuleStatusIcon(
                key: key,
                status: status,
                color: color,
                size: iconSize,
              ),
              final IconData iconData => Icon(
                iconData,
                key: key,
                size: iconSize,
                color: color,
              ),
            },
          ),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: duration,
              style: textStyle.copyWith(color: color),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows how far the text in [controller] is from satisfying [rules].
///
/// Place it under the password field and give it the same controller. It
/// fills the available width and takes the height it needs. While the field
/// is empty every rule is drawn in [defaultColor] with a ring; afterwards
/// each rule is drawn in [successColor] with a check or in [failureColor] with
/// a cross, and the bar fills one segment per passing rule. Every change
/// animates over [animationDuration] unless the platform asks for animations
/// to be disabled.
///
/// It depends only on `package:flutter/widgets.dart`, so it works the same
/// under `package:material_ui`, the older `package:flutter/material.dart`,
/// Cupertino, or a design system of your own. The labels take the
/// surrounding text style, which Material and Cupertino apps set from their
/// theme.
///
/// ```dart
/// FlutterPwValidator(
///   controller: passwordController,
///   rules: const PasswordRules(minLength: 8, uppercase: 1, digits: 1),
///   onChanged: (validation) => setState(() => canSubmit = validation.isValid),
/// )
/// ```
///
/// Pass a `GlobalKey<FlutterPwValidatorState>` to call
/// [FlutterPwValidatorState.validate] from a submit button; the widget shakes
/// when that finds the password invalid. A [MatchRule] over a confirmation
/// field needs that field's controller in [listenables]. Pass [itemBuilder]
/// or [barBuilder] to draw the rows or the bar yourself, and [strengthOf] to
/// rate the password with your own estimator.
class FlutterPwValidator extends StatefulWidget {
  /// Creates the validator for [controller] against [rules].
  const FlutterPwValidator({
    super.key,
    required this.controller,
    required this.rules,
    this.listenables = const [],
    this.onSuccess,
    this.onFail,
    this.onChanged,
    this.strings = const FlutterPwValidatorStrings(),
    this.defaultColor,
    this.successColor,
    this.failureColor,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
    this.barThickness = 4,
    this.barStyle = PasswordBarStyle.segments,
    this.showBar = true,
    this.showList = true,
    this.showStrengthLabel = false,
    this.shakeOnInvalid = true,
    this.neutralIcon,
    this.successIcon,
    this.failureIcon,
    this.animationDuration = const Duration(milliseconds: 200),
    this.itemBuilder,
    this.barBuilder,
    this.strengthOf,
  });

  /// The controller of the password field.
  final TextEditingController controller;

  /// The rules the password has to satisfy.
  final PasswordRules rules;

  /// Other sources of change to re-evaluate on, such as the controller of a
  /// confirmation field that a [MatchRule] reads.
  final List<Listenable> listenables;

  /// Called after every change that leaves the password valid.
  final VoidCallback? onSuccess;

  /// Called after every change that leaves the password invalid.
  final VoidCallback? onFail;

  /// Called after every change with the full result, before [onSuccess] or
  /// [onFail].
  final ValueChanged<PasswordValidation>? onChanged;

  /// The labels of the rules and of the strength levels.
  final FlutterPwValidatorStrings strings;

  /// Color of a rule before any text is entered, and of the bar's empty
  /// track. Defaults to the label color at 60 percent opacity, or the gray of
  /// version 1 when the label style has no color.
  final Color? defaultColor;

  /// Color of a passing rule. Defaults to the green of version 1.
  final Color? successColor;

  /// Color of a failing rule. Defaults to the red of version 1.
  final Color? failureColor;

  /// Style of the rule labels. Defaults to the surrounding
  /// `DefaultTextStyle`, which a Material app sets to its theme's
  /// `bodyMedium`.
  final TextStyle? textStyle;

  /// Padding around the whole widget.
  final EdgeInsetsGeometry padding;

  /// Vertical gap between the bar and the list of rules.
  final double spacing;

  /// Height of the bar.
  final double barThickness;

  /// Whether the bar is segmented or one continuous track.
  final PasswordBarStyle barStyle;

  /// Whether to show the bar.
  final bool showBar;

  /// Whether to show the list of rules.
  final bool showList;

  /// Whether to show the strength level above the bar, named by
  /// [FlutterPwValidatorStrings.strength]. Weak uses [failureColor], strong
  /// uses [successColor], the levels between use [defaultColor].
  final bool showStrengthLabel;

  /// Whether [FlutterPwValidatorState.validate] shakes the widget when the
  /// password is invalid. Typing never shakes.
  final bool shakeOnInvalid;

  /// Icon of every rule before any text is entered, from an icon font such as
  /// `Icons`. Without one the widget draws [PasswordRuleStatusIcon]'s ring.
  final IconData? neutralIcon;

  /// Icon of a passing rule. Without one the widget draws
  /// [PasswordRuleStatusIcon]'s check.
  final IconData? successIcon;

  /// Icon of a failing rule. Without one the widget draws
  /// [PasswordRuleStatusIcon]'s cross.
  final IconData? failureIcon;

  /// How long color and icon changes take. Ignored, as zero, when the
  /// platform disables animations.
  final Duration animationDuration;

  /// Draws one rule row instead of the default icon and label.
  final PasswordRuleItemBuilder? itemBuilder;

  /// Draws the bar instead of the default segments.
  final PasswordBarBuilder? barBuilder;

  /// Rates the password for the strength label instead of
  /// [PasswordValidation.strength].
  final PasswordStrengthCalculator? strengthOf;

  @override
  FlutterPwValidatorState createState() => FlutterPwValidatorState();
}

/// The state of a [FlutterPwValidator]; reach it through a `GlobalKey` to
/// call [validate].
class FlutterPwValidatorState extends State<FlutterPwValidator>
    with SingleTickerProviderStateMixin {
  late PasswordValidation _validation;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: _shakeDuration,
  );

  void _evaluate() {
    _validation = widget.rules.validate(widget.controller.text);
  }

  /// Re-evaluates, repaints and fires the callbacks; returns whether the
  /// password is valid.
  bool _validate() {
    setState(_evaluate);
    widget.onChanged?.call(_validation);
    final isValid = _validation.isValid;
    if (isValid) {
      widget.onSuccess?.call();
    } else {
      widget.onFail?.call();
    }
    return isValid;
  }

  void _onNotified() => _validate();

  void _listen(Iterable<Listenable> listenables) {
    for (final listenable in listenables) {
      listenable.addListener(_onNotified);
    }
  }

  void _unlisten(Iterable<Listenable> listenables) {
    for (final listenable in listenables) {
      listenable.removeListener(_onNotified);
    }
  }

  /// Re-evaluates the password, repaints, calls [FlutterPwValidator.onChanged]
  /// then [FlutterPwValidator.onSuccess] or [FlutterPwValidator.onFail],
  /// shakes the widget when the password is invalid and
  /// [FlutterPwValidator.shakeOnInvalid] is on, and returns whether it is
  /// valid.
  bool validate() {
    final isValid = _validate();
    if (!isValid &&
        widget.shakeOnInvalid &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
    return isValid;
  }

  @override
  void initState() {
    super.initState();
    _evaluate();
    _listen([widget.controller, ...widget.listenables]);
  }

  @override
  void didUpdateWidget(FlutterPwValidator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unlisten([oldWidget.controller, ...oldWidget.listenables]);
    _listen([widget.controller, ...widget.listenables]);
    if (oldWidget.controller != widget.controller ||
        oldWidget.rules != widget.rules) {
      _evaluate();
    }
  }

  @override
  void dispose() {
    _unlisten([widget.controller, ...widget.listenables]);
    _shake.dispose();
    super.dispose();
  }

  Color _strengthColor(
    PasswordStrength strength, {
    required Color defaultColor,
    required Color successColor,
    required Color failureColor,
  }) => switch (strength) {
    PasswordStrength.weak => failureColor,
    PasswordStrength.fair || PasswordStrength.good => defaultColor,
    PasswordStrength.strong => successColor,
  };

  Widget _buildRow(
    BuildContext context,
    PasswordRuleItem item, {
    required Color color,
    required TextStyle textStyle,
    required Duration duration,
  }) {
    final builder = widget.itemBuilder;
    if (builder != null) {
      // A built row keeps its own labels but stays a node of its own, like
      // the default row.
      return Semantics(container: true, child: builder(context, item));
    }
    return _RuleRow(
      status: item.status,
      icon: switch (item.status) {
        PasswordRuleStatus.neutral => widget.neutralIcon,
        PasswordRuleStatus.passed => widget.successIcon,
        PasswordRuleStatus.failed => widget.failureIcon,
      },
      label: item.label,
      semanticsLabel: switch (item.status) {
        PasswordRuleStatus.neutral => item.label,
        PasswordRuleStatus.passed => '${item.label}, ${widget.strings.ruleMet}',
        PasswordRuleStatus.failed =>
          '${item.label}, ${widget.strings.ruleNotMet}',
      },
      color: color,
      textStyle: textStyle,
      duration: duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
    final textColor = textStyle.color;
    final defaultColor =
        widget.defaultColor ??
        textColor?.withValues(alpha: textColor.a * _neutralOpacity) ??
        _neutralGray;
    final successColor = widget.successColor ?? _successGreen;
    final failureColor = widget.failureColor ?? _failureRed;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.animationDuration;
    final isEmpty = widget.controller.text.isEmpty;
    final results = _validation.results;
    final passed = isEmpty ? 0 : results.values.where((value) => value).length;
    final score = isEmpty ? 0.0 : _validation.score;
    final strength =
        widget.strengthOf?.call(widget.controller.text, _validation) ??
        _validation.strength;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeOffset(_shake.value), 0),
        child: child,
      ),
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showStrengthLabel) ...[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  style: textStyle.copyWith(
                    color: isEmpty
                        ? defaultColor
                        : _strengthColor(
                            strength,
                            defaultColor: defaultColor,
                            successColor: successColor,
                            failureColor: failureColor,
                          ),
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(isEmpty ? '' : widget.strings.strength(strength)),
                ),
              ),
              const SizedBox(height: _labelSpacing),
            ],
            if (widget.showBar)
              widget.barBuilder?.call(context, passed, results.length) ??
                  switch (widget.barStyle) {
                    PasswordBarStyle.segments => _ValidationBar(
                      passed: passed,
                      total: results.length,
                      thickness: widget.barThickness,
                      successColor: successColor,
                      defaultColor: defaultColor,
                      duration: duration,
                    ),
                    PasswordBarStyle.continuous => _ContinuousBar(
                      fraction: score,
                      thickness: widget.barThickness,
                      fillColor: Color.lerp(failureColor, successColor, score)!,
                      trackColor: defaultColor,
                      duration: duration,
                    ),
                  },
            if (widget.showBar && widget.showList)
              SizedBox(height: widget.spacing),
            if (widget.showList)
              Column(
                spacing: _rowSpacing,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final MapEntry(key: rule, value: isPassing)
                      in results.entries)
                    _buildRow(
                      context,
                      PasswordRuleItem(
                        rule: rule,
                        label: widget.strings.of(rule),
                        status: isEmpty
                            ? PasswordRuleStatus.neutral
                            : isPassing
                            ? PasswordRuleStatus.passed
                            : PasswordRuleStatus.failed,
                      ),
                      color: isEmpty
                          ? defaultColor
                          : isPassing
                          ? successColor
                          : failureColor,
                      textStyle: textStyle,
                      duration: duration,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

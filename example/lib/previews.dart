// Widget previews for the Flutter widget previewer: open this file in an
// IDE with the previewer, or run `flutter widget-preview start` in example/.
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

const PasswordRules _rules = PasswordRules(
  minLength: 8,
  uppercase: 1,
  digits: 1,
  special: 1,
);
const double _previewPadding = 16;

/// Wraps a preview in a Material app so theme and text direction resolve.
Widget materialWrapper(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

Widget _validator(
  String text, {
  PasswordBarStyle barStyle = PasswordBarStyle.segments,
  FlutterPwValidatorStrings strings = const FlutterPwValidatorStrings(),
}) => Padding(
  padding: const EdgeInsets.all(_previewPadding),
  child: FlutterPwValidator(
    controller: TextEditingController(text: text),
    rules: _rules,
    strings: strings,
    barStyle: barStyle,
    showStrengthLabel: true,
  ),
);

/// The neutral state before any text.
@Preview(name: 'Empty', wrapper: materialWrapper)
Widget empty() => _validator('');

/// Two of four rules passing.
@Preview(name: 'Partial', wrapper: materialWrapper)
Widget partial() => _validator('abc1');

/// Every rule passing.
@Preview(name: 'Valid', wrapper: materialWrapper)
Widget valid() => _validator('Abcdefg1!');

/// The continuous bar style.
@Preview(name: 'Continuous bar', wrapper: materialWrapper)
Widget continuous() =>
    _validator('abc1', barStyle: PasswordBarStyle.continuous);

/// The Persian labels, right to left.
@Preview(name: 'Persian', wrapper: materialWrapper)
Widget persian() => Directionality(
  textDirection: TextDirection.rtl,
  child: _validator('abc1', strings: const FlutterPwValidatorStrings.persian()),
);

/// The valid state in the dark theme.
@Preview(name: 'Dark', wrapper: materialWrapper, brightness: Brightness.dark)
Widget dark() => _validator('Abcdefg1!');

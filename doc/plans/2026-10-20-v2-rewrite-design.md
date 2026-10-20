# flutter_pw_validator 2.0 rewrite

Date: 2026-10-20

## Intent

The package last shipped in May 2023 (1.6.0) and still serves about 2,800 downloads a month.
Every open pull request, most forks, and most issues ask for the same things: drop the required
`width` and `height`, let the text be styled, control padding and spacing, show check and cross
icons, and reuse the rules outside the widget. Version 2.0 rewrites the package from scratch
around those requests and modern Dart.

## Goals

- Rules are a pure-Dart value (`PasswordRules`) that can be evaluated anywhere, including a
  `TextFormField.validator` or a reset-password flow (issue 23).
- Counting is Unicode-aware: letters, uppercase, lowercase, digits and special characters are
  Unicode categories, so Persian, Cyrillic or accented passwords count correctly.
- The widget sizes itself: fills the available width, takes the height it needs (issue 7,
  pull request 29).
- Styling comes from the app theme by default and every visual knob is an optional parameter:
  colors, text style, padding, spacing, bar thickness, icons, and which of the bar and the list
  to show (issues 12, 21, 32, pull requests 28 and 29).
- Lifecycle is correct: the controller listener is removed on dispose, a swapped controller or
  changed rules and strings are picked up in `didUpdateWidget` (issue 30), and a pre-filled
  controller is evaluated on first build.
- Strings are a const value with named parameters, so a translation is one constructor call
  (issues 18 and 31), and each string is a function of the count so plurals read correctly.
- Tooling matches a 2026 package: `flutter_lints`, snake_case files, CI on GitHub Actions,
  `topics` and `screenshots` in the pubspec, widget tests next to the unit tests.

## Non-goals

- Showing the widget only while the field has focus (issue 24): wrap it in `Visibility`.
- Password strength scoring (zxcvbn and the like): other packages cover it.
- A verified pub.dev publisher: needs a domain.

## Public API

```dart
sealed class PasswordRule { bool test(String password); }
sealed class CountRule extends PasswordRule { final int count; }   // value equality
final class MinLengthRule, MaxLengthRule, LettersRule, UppercaseRule, LowercaseRule,
            DigitsRule, SpecialCharactersRule extends CountRule
final class CustomRule extends PasswordRule { const CustomRule({label, test}); }

class PasswordRules {
  const PasswordRules({minLength = 0, maxLength = 0, letters = 0, uppercase = 0,
      lowercase = 0, digits = 0, special = 0, custom = const []});
  List<PasswordRule> get active;                // built-ins above zero, then custom
  PasswordValidation validate(String password);
  String? Function(String?) formValidator({strings, separator = ', '});
}

class PasswordValidation {
  Map<PasswordRule, bool> get results;          // one entry per active rule
  bool get isValid;
  List<PasswordRule> get failed;
  double get score;                             // passing over active, 1.0 with no rules
  PasswordStrength get strength;                // weak < 0.5 <= fair < 0.75 <= good < 1 = strong
}

class FlutterPwValidatorStrings {
  const FlutterPwValidatorStrings({minLength, maxLength, letters, uppercase, lowercase,
      digits, special, strength, ruleMet, ruleNotMet});
  const FlutterPwValidatorStrings.persian({...});   // same parameters, Persian defaults
  // Each rule parameter is `String Function(int count)`; English defaults handle plurals.
  String of(PasswordRule rule);                     // a CustomRule returns its own label
}

class FlutterPwValidator extends StatefulWidget {
  const FlutterPwValidator({
    super.key,
    required TextEditingController controller,
    required PasswordRules rules,
    VoidCallback? onSuccess,
    VoidCallback? onFail,
    ValueChanged<PasswordValidation>? onChanged,
    FlutterPwValidatorStrings strings = const FlutterPwValidatorStrings(),
    Color? defaultColor,            // theme: colorScheme.outline
    Color? successColor,            // package green, same as 1.x
    Color? failureColor,            // theme: colorScheme.error
    TextStyle? textStyle,           // theme: textTheme.bodyMedium
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double spacing = 12,            // between the bar and the list
    double barThickness = 4,
    bool showBar = true,
    bool showList = true,
    bool showStrengthLabel = false,
    IconData neutralIcon = Icons.radio_button_unchecked,
    IconData successIcon = Icons.check_circle,
    IconData failureIcon = Icons.cancel,
    Duration animationDuration = const Duration(milliseconds: 200),
    PasswordRuleItemBuilder? itemBuilder,   // (context, PasswordRuleItem) → row
    PasswordBarBuilder? barBuilder,         // (context, passed, total) → bar
    PasswordStrengthCalculator? strengthOf, // (password, validation) → PasswordStrength
  });
}

enum PasswordStrength { weak, fair, good, strong }
enum PasswordRuleStatus { neutral, passed, failed }
class PasswordRuleItem { rule, label, status }

class FlutterPwValidatorState {
  bool validate();                  // re-evaluates, repaints, fires callbacks, returns isValid
}
```

## Behaviour

- Counting: `minLength` counts user-perceived characters (grapheme clusters). `letters` counts
  `\p{L}`, `uppercase` `\p{Lu}`, `lowercase` `\p{Ll}`, `digits` `\p{Nd}`, and `special` any
  character that is not a letter, mark, number or whitespace.
- Neutral state: while the controller text is empty every row uses `defaultColor` and the
  success icon; the bar is all `defaultColor`. Once text exists, a passing rule is drawn in
  `successColor` with the success icon and a failing one in `failureColor` with the failure icon.
  The bar fills one segment per passing rule, from the left.
- Callbacks: `onSuccess` fires on every change that leaves the password valid and `onFail` on
  every change that leaves it invalid, the same contract as 1.x. Neither fires on first build
  or when the parent swaps rules, strings or controller.
- Strings are read from the widget on every build and never cached in state.
- Motion: bar segments, row colors and icons animate over `animationDuration`;
  `MediaQuery.disableAnimations` forces zero.
- Strength: the share of passing rules, weak below one half, fair from one half, good from
  three quarters, strong when every rule passes. Weak is drawn in `failureColor`, strong in
  `successColor`, the two levels between in `defaultColor`. Hidden while the text is empty.
- Builders: `itemBuilder` replaces the whole row, `barBuilder` the whole bar; both receive
  the resolved state, never raw colors, so a custom look stays the caller's.
- Accessibility: a default row is one semantics node, "label, met" or "label, not met"
  (just the label while neutral), with the words from `strings`. A built row keeps its own.
- Custom rules and `maxLength` came from the competitor survey (`fancy_password_field`,
  `password_rule_check`, `password_validator_mate`): the rule set had to be open before 2.0
  shipped, since an enum cannot grow later without a break. `strengthOf` is the answer to
  entropy estimators (`zxcvbnm`, `password_strength`) without taking on their dictionaries.

## Non-goals, from the survey

A full password field with a visibility toggle (`fancy_password_field`'s lane), a password
generator, a bundled breached-password list, keyboard-pattern detection.

## Migration from 1.x

| 1.x | 2.0 |
|-----|-----|
| `minLength`, `normalCharCount`, `uppercaseCharCount`, `lowercaseCharCount`, `numericCharCount`, `specialCharCount` | `rules: PasswordRules(minLength:, letters:, uppercase:, lowercase:, digits:, special:)` |
| `width`, `height` (required) | removed; wrap in `SizedBox` to constrain |
| `onSuccess` (required) | optional |
| `class MyStrings implements FlutterPwValidatorStrings` with `"- Uppercase letter"` | `FlutterPwValidatorStrings(uppercase: (count) => '$count uppercase letters')` |
| `GlobalKey<FlutterPwValidatorState>` + `validate()` | unchanged |

## Layout of the repository

```
lib/flutter_pw_validator.dart            re-exports password_rules, exports the widget
lib/src/flutter_pw_validator.dart        widget, state, private bar and row widgets,
                                         FlutterPwValidatorStrings alias
test/src/flutter_pw_validator_test.dart  widget tests
example/lib/main.dart                    sign-up screen: field, validator, confirmation,
                                         suggest and submit buttons
example/lib/previews.dart                @Preview functions for the widget previewer
screenshots/                             pubspec screenshots, also used by the README
.github/workflows/ci.yml                 format, analyze, test, publish dry run
```

The rules live in their own repository, `ArefMozafari/password_rules`, published as
`password_rules`; this package depends on the hosted version. While both change together, an
untracked `pubspec_overrides.yaml` (and one in `example/`) points at a sibling checkout,
`../password_rules`. Release order: `password_rules` first, then `flutter_pw_validator`.

A monorepo was tried first and rejected: pub applies every ancestor ignore file, so a root
`.pubignore` that keeps the nested package out of the Flutter archive also hides the nested
package's own pubspec when publishing it, and a root `flutter analyze` walks into the nested
tests without their dependencies.

## Additions from the competitor survey, second pass

- `password_rules`: the rules had no Flutter import, so the split lets a Dart backend enforce
  the policy the app shows.
- `PasswordRules.nist()`: NIST SP 800-63B-4 asks for 15 characters alone or 8 with a second
  factor, at least 64 accepted, no composition rules, and a blocklist. The preset is that.
- `CommonPasswordsRule`: the SecLists top-1000 list, lowercased and generated into Dart by
  a committed tool, is the smallest list that satisfies the blocklist requirement.
- `generate()`: picks the required characters first, fills to the length, shuffles, then
  re-checks custom rules up to a hundred times. `MatchRule` is skipped.
- `MatchRule` plus `listenables`: the widget listens to the confirmation controller and
  re-evaluates; the rule reads the value through a getter so the rules stay a value.
- `PasswordBarStyle.continuous`: one track, fill equals the score, color lerped from failure
  to success, since a mid level in the outline color would be invisible on the track.
- Shake: only `validate()` from a key shakes, never typing; off under reduced motion.
- `@Preview` functions in the example for the widget previewer.

## Tooling decisions

- `sdk: ^3.8.0`, `flutter: >=3.32.0`: the floor `flutter_lints` 6 requires, and new enough
  for the tall formatter style.
- `dart format` at the default 80 columns, the pub.dev convention.
- The example app's platform folders are regenerated with `flutter create` so the example
  runs on current toolchains.

## Left to the builder

- Exact spacing between icon and label and between rows.
- The CI matrix (stable only is enough).

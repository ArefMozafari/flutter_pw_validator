## 2.0.0

A rewrite from scratch. Breaking changes are listed under Migration.

### Added

* The rules moved to the new dependency-free `password_rules` package,
  re-exported here, so a Dart backend enforces the same policy.
  `PasswordRules` holds the counts and any further `PasswordRule`, with
  `validate(password)` returning a `PasswordValidation` (`results`,
  `isValid`, `failed`, `score`, `strength`), `formValidator()` for a
  `TextFormField`, and `generate()` for a password that passes every rule.
* `maxLength`, `CustomRule`, `CommonPasswordsRule` over the SecLists top-1000
  list, `MatchRule` for a confirmation field, and `PasswordRules.nist()` for
  NIST SP 800-63B-4. Each rule is a `PasswordRule` subclass with its own
  `test`.
* `onChanged` with the full validation, `strengthOf` to plug an entropy
  estimator into the strength label, `listenables` to re-check when another
  controller changes.
* `barStyle: PasswordBarStyle.continuous`, one track that fills with the
  score, and a shake when `validate()` finds the password invalid
  (`shakeOnInvalid`).
* `@Preview` widget previews in the example.
* `FlutterPwValidatorStrings` is now an alias of `PasswordRuleStrings`;
  `.persian()` is a complete Persian set with Persian digits, and `ruleMet`
  and `ruleNotMet` serve screen readers.
* Each rule row carries a semantics label, "1 digit, met", so screen readers
  announce the state.
* Unicode-aware counting: letters and digits from any script count, uppercase
  and lowercase use Unicode categories, and a special character is anything
  that is not a letter, mark, number or whitespace. `minLength` counts
  user-perceived characters, so an emoji sequence counts once.
* Animated state changes (`animationDuration`, 200 ms by default, zero when
  the platform disables animations).
* Filled icons by default: `radio_button_unchecked` before any text,
  `check_circle` for a passing rule, `cancel` for a failing one, each
  replaceable through `neutralIcon`, `successIcon` and `failureIcon`.
* `showStrengthLabel` shows Weak, Fair, Good or Strong above the bar; the
  level is also available as `PasswordValidation.strength`.
* `itemBuilder` and `barBuilder` to draw the rows or the bar yourself.
* `textStyle`, `padding`, `spacing`, `barThickness`, `showBar` and `showList`
  parameters.
* Colors default to the app theme: `colorScheme.outline` before any text,
  `colorScheme.error` for a failing rule, `bodyMedium` for the labels.
* `FlutterPwValidatorStrings` takes one function per rule and one for the
  strength levels, so a translation can handle plurals and digit shapes.
* Widget tests, `flutter_lints`, a GitHub Actions workflow and pub.dev
  screenshots.

### Fixed

* The controller listener is removed when the widget is disposed.
* Changing `strings`, `rules` or `controller` on a mounted widget is applied
  (issue 30).
* A pre-filled controller is evaluated on first build instead of after the
  first keystroke.

### Migration from 1.x

* `minLength`, `normalCharCount`, `uppercaseCharCount`, `lowercaseCharCount`,
  `numericCharCount` and `specialCharCount` moved into
  `rules: PasswordRules(minLength:, letters:, uppercase:, lowercase:, digits:,
  special:)`.
* `width` and `height` are gone; the widget fills the available width and
  sizes its own height. Wrap it in a `SizedBox` to constrain it.
* `onSuccess` is optional.
* A translation is `FlutterPwValidatorStrings(uppercase: (count) => '...')`
  instead of a subclass with `"- Uppercase letter"` fields.
* Package files moved under `lib/src/`; import only
  `package:flutter_pw_validator/flutter_pw_validator.dart`.
* Requires Dart 3.8 and Flutter 3.32 or newer.

## [1.6.0] - 2022-5-17

* New Feature: Validation for lowercase letters. Thanks to [BrunoPereira](https://github.com/BrunoPereira-2331)

## [1.5.0] - 2022-12-08

* New Feature: Add Key property to access to the validate function (See the example)
* chore: Update gradle, kotlin, flutter version and the example app

## [1.4.2] - 2022-03-01

* New Feature: Validation for normal letters. Thanks to [jeffersonmello](https://github.com/jeffersonmello)

## [1.4.1] - 2022/02/10

* BUG FIX: [setState() called after dispose()](https://github.com/ArefMozafari/flutter_pw_validator/issues/16). Thanks to [Money1998](https://github.com/Money1998)

## [1.4.0+1] - 2022/01/27

* Readme Updated

## [1.4.0] - 2022/01/27

* New Feature: Added an OnFail callback that gets called everytime the password doesn't match.
* Update example project

## [1.3.0] - 2021/10/23

* Support for i18n, to translate conditions. Thanks to [HugoHeneault](https://github.com/HugoHeneault)
  
## [1.2.1] - 2021/03/27

* Support for _ (Underscore) as special character. Thanks to [adithyaakrishna](https://github.com/adithyaakrishna)

## [1.2.0] - 2021/03/25

* Sound null safety added.

## [1.0.1+1] - 2021/02/18

* README updated.

## [1.0.1] - 2021/02/18

* documents updated.

## [1.0.0] - 2021/02/08

* Initial release.

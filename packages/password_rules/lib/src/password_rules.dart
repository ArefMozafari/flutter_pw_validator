import 'dart:math';

import 'package:characters/characters.dart';

import 'common_passwords.dart';
import 'password_rule_strings.dart';

final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _uppercaseLetter = RegExp(r'\p{Lu}', unicode: true);
final RegExp _lowercaseLetter = RegExp(r'\p{Ll}', unicode: true);
final RegExp _digit = RegExp(r'\p{Nd}', unicode: true);
final RegExp _specialCharacter = RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true);

/// Characters [PasswordRules.generate] draws from, one set per count rule.
const String _generatedUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String _generatedLowercase = 'abcdefghijklmnopqrstuvwxyz';
const String _generatedDigits = '0123456789';
const String _generatedSpecial = r'!@#$%^&*()-_=+[]{};:,.?';
const String _generatedAny =
    _generatedUppercase +
    _generatedLowercase +
    _generatedDigits +
    _generatedSpecial;

/// How many candidates [PasswordRules.generate] tries before giving up on
/// custom rules it cannot construct for.
const int _generateAttempts = 100;

int _matches(RegExp pattern, String password) =>
    pattern.allMatches(password).length;

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

/// A requirement a password can be checked against.
///
/// The built-in rules are [MinLengthRule], [MaxLengthRule], [LettersRule],
/// [UppercaseRule], [LowercaseRule], [DigitsRule], [SpecialCharactersRule],
/// [CommonPasswordsRule] and [MatchRule]; [CustomRule] wraps any predicate.
sealed class PasswordRule {
  const PasswordRule();

  /// Whether [password] satisfies this rule.
  bool test(String password);
}

/// A built-in rule about how many of something the password contains.
///
/// Two count rules are equal when they are the same kind with the same count.
sealed class CountRule extends PasswordRule {
  const CountRule(this.count)
    : assert(count > 0, 'A rule count must be above zero.');

  /// The count the rule requires or allows.
  final int count;

  @override
  bool operator ==(Object other) =>
      other is CountRule &&
      other.runtimeType == runtimeType &&
      other.count == count;

  @override
  int get hashCode => Object.hash(runtimeType, count);

  @override
  String toString() => '$runtimeType($count)';
}

/// The password has at least [count] user-perceived characters.
final class MinLengthRule extends CountRule {
  /// Creates the rule.
  const MinLengthRule(super.count);

  @override
  bool test(String password) => password.characters.length >= count;
}

/// The password has at most [count] user-perceived characters.
final class MaxLengthRule extends CountRule {
  /// Creates the rule.
  const MaxLengthRule(super.count);

  @override
  bool test(String password) => password.characters.length <= count;
}

/// The password contains at least [count] letters, from any script.
final class LettersRule extends CountRule {
  /// Creates the rule.
  const LettersRule(super.count);

  @override
  bool test(String password) => _matches(_letter, password) >= count;
}

/// The password contains at least [count] uppercase letters.
final class UppercaseRule extends CountRule {
  /// Creates the rule.
  const UppercaseRule(super.count);

  @override
  bool test(String password) => _matches(_uppercaseLetter, password) >= count;
}

/// The password contains at least [count] lowercase letters.
final class LowercaseRule extends CountRule {
  /// Creates the rule.
  const LowercaseRule(super.count);

  @override
  bool test(String password) => _matches(_lowercaseLetter, password) >= count;
}

/// The password contains at least [count] decimal digits, from any script.
final class DigitsRule extends CountRule {
  /// Creates the rule.
  const DigitsRule(super.count);

  @override
  bool test(String password) => _matches(_digit, password) >= count;
}

/// The password contains at least [count] characters that are not letters,
/// combining marks, numbers or whitespace.
final class SpecialCharactersRule extends CountRule {
  /// Creates the rule.
  const SpecialCharactersRule(super.count);

  @override
  bool test(String password) => _matches(_specialCharacter, password) >= count;
}

/// The password is not one of the thousand most common leaked passwords,
/// compared case-insensitively.
///
/// NIST SP 800-63B requires a blocklist check; this is the smallest useful
/// one. For a larger or a live list, write a [CustomRule] over your own set.
final class CommonPasswordsRule extends PasswordRule {
  /// Creates the rule.
  const CommonPasswordsRule();

  @override
  bool test(String password) =>
      !commonPasswords.contains(password.toLowerCase());

  @override
  bool operator ==(Object other) => other is CommonPasswordsRule;

  @override
  int get hashCode => (CommonPasswordsRule).hashCode;

  @override
  String toString() => 'CommonPasswordsRule';
}

/// The password equals the value [other] returns, typically the text of a
/// confirmation field.
///
/// [PasswordRules.generate] skips this rule, since the confirmation is typed
/// after the password.
final class MatchRule extends PasswordRule {
  /// Creates the rule from a getter of the value to match.
  const MatchRule(this.other);

  /// Returns the value the password has to equal.
  final String Function() other;

  @override
  bool test(String password) => password == other();

  @override
  String toString() => 'MatchRule';
}

/// A rule defined by the caller: a [label] already in the user's language and
/// a predicate.
///
/// ```dart
/// const noSpaces = CustomRule(
///   label: 'No spaces',
///   test: _hasNoSpaces,
/// );
/// ```
final class CustomRule extends PasswordRule {
  /// Creates the rule from its label and predicate.
  const CustomRule({required this.label, required bool Function(String) test})
    : _test = test;

  /// The text shown next to the rule.
  final String label;

  final bool Function(String password) _test;

  @override
  bool test(String password) => _test(password);

  @override
  String toString() => 'CustomRule($label)';
}

/// How much of a [PasswordRules] a password satisfies.
enum PasswordStrength {
  /// Fewer than half of the active rules pass.
  weak,

  /// At least half of the active rules pass.
  fair,

  /// At least three quarters of the active rules pass.
  good,

  /// Every active rule passes.
  strong,
}

/// The outcome of checking one password against a [PasswordRules].
class PasswordValidation {
  const PasswordValidation._(this.results);

  static const double _fairRatio = 0.5;
  static const double _goodRatio = 0.75;

  /// Whether each active rule passed, in display order.
  final Map<PasswordRule, bool> results;

  /// Whether every active rule passed.
  bool get isValid => results.values.every((passed) => passed);

  /// The active rules that did not pass, in display order.
  List<PasswordRule> get failed => [
    for (final MapEntry(key: rule, value: passed) in results.entries)
      if (!passed) rule,
  ];

  /// The share of passing rules, from 0.0 to 1.0; 1.0 when no rule is active.
  double get score => results.isEmpty
      ? 1
      : results.values.where((passed) => passed).length / results.length;

  /// [score] bucketed into four levels.
  PasswordStrength get strength {
    if (isValid) {
      return PasswordStrength.strong;
    }
    if (score >= _goodRatio) {
      return PasswordStrength.good;
    }
    if (score >= _fairRatio) {
      return PasswordStrength.fair;
    }
    return PasswordStrength.weak;
  }
}

/// The rules a password has to satisfy.
///
/// A count of zero disables its rule. Counting is Unicode-aware: letters and
/// digits from any script count, and a special character is anything that is
/// not a letter, a combining mark, a number, or whitespace. [minLength] and
/// [maxLength] count user-perceived characters, so an emoji sequence counts
/// once. [custom] rules run after the built-in ones.
///
/// The rules are a plain value, so the same instance can drive a Flutter
/// widget, a `TextFormField.validator` and a backend:
///
/// ```dart
/// const rules = PasswordRules(minLength: 8, uppercase: 1, digits: 1);
/// final validation = rules.validate(password);
/// final suggestion = rules.generate();
/// ```
class PasswordRules {
  /// Creates the rules. Every count has to be zero or more.
  const PasswordRules({
    this.minLength = 0,
    this.maxLength = 0,
    this.letters = 0,
    this.uppercase = 0,
    this.lowercase = 0,
    this.digits = 0,
    this.special = 0,
    this.custom = const [],
  }) : assert(
         minLength >= 0 &&
             maxLength >= 0 &&
             letters >= 0 &&
             uppercase >= 0 &&
             lowercase >= 0 &&
             digits >= 0 &&
             special >= 0,
         'A rule count must not be negative.',
       );

  /// The policy of NIST SP 800-63B-4: at least 15 characters, or 8 when the
  /// password is one factor of several ([multiFactor]), up to 64 accepted,
  /// no composition rules, and a blocklist check ([CommonPasswordsRule]).
  const PasswordRules.nist({bool multiFactor = false})
    : minLength = multiFactor ? _nistMultiFactorMinLength : _nistMinLength,
      maxLength = _nistMaxLength,
      letters = 0,
      uppercase = 0,
      lowercase = 0,
      digits = 0,
      special = 0,
      custom = const [CommonPasswordsRule()];

  static const int _nistMinLength = 15;
  static const int _nistMultiFactorMinLength = 8;
  static const int _nistMaxLength = 64;

  /// The minimum number of user-perceived characters.
  final int minLength;

  /// The maximum number of user-perceived characters.
  final int maxLength;

  /// The minimum number of letters, from any script.
  final int letters;

  /// The minimum number of uppercase letters.
  final int uppercase;

  /// The minimum number of lowercase letters.
  final int lowercase;

  /// The minimum number of decimal digits, from any script.
  final int digits;

  /// The minimum number of characters that are not letters, marks, numbers,
  /// or whitespace.
  final int special;

  /// Further rules, checked after the built-in counts: [CustomRule],
  /// [CommonPasswordsRule], [MatchRule], or any other [PasswordRule].
  final List<PasswordRule> custom;

  /// The rules in effect, in display order: the built-in counts above zero,
  /// then [custom].
  List<PasswordRule> get active => [
    if (minLength > 0) MinLengthRule(minLength),
    if (maxLength > 0) MaxLengthRule(maxLength),
    if (letters > 0) LettersRule(letters),
    if (uppercase > 0) UppercaseRule(uppercase),
    if (lowercase > 0) LowercaseRule(lowercase),
    if (digits > 0) DigitsRule(digits),
    if (special > 0) SpecialCharactersRule(special),
    ...custom,
  ];

  /// Checks [password] against every active rule.
  PasswordValidation validate(String password) => PasswordValidation._({
    for (final rule in active) rule: rule.test(password),
  });

  /// A validator for `TextFormField` that returns null for a valid password
  /// and otherwise the labels of the failing rules joined by [separator].
  String? Function(String? value) formValidator({
    PasswordRuleStrings strings = const PasswordRuleStrings(),
    String separator = ', ',
  }) => (value) {
    final validation = validate(value ?? '');
    if (validation.isValid) {
      return null;
    }
    return validation.failed.map(strings.of).join(separator);
  };

  static String _pick(String characters, Random random) =>
      characters[random.nextInt(characters.length)];

  /// The characters every generated password has to contain: one per
  /// required uppercase letter, lowercase letter, digit and special
  /// character, plus lowercase letters until [letters] is met.
  List<String> _requiredCharacters(Random random) => [
    for (var index = 0; index < uppercase; index++)
      _pick(_generatedUppercase, random),
    for (var index = 0; index < lowercase; index++)
      _pick(_generatedLowercase, random),
    for (var index = 0; index < digits; index++)
      _pick(_generatedDigits, random),
    for (var index = 0; index < special; index++)
      _pick(_generatedSpecial, random),
    for (var index = uppercase + lowercase; index < letters; index++)
      _pick(_generatedLowercase, random),
  ];

  /// Whether [candidate] passes every active rule except [MatchRule].
  bool _acceptsGenerated(String candidate) => active
      .where((rule) => rule is! MatchRule)
      .every((rule) => rule.test(candidate));

  /// Builds a random ASCII password that satisfies every active rule.
  ///
  /// The result has [length] characters, grown to fit [minLength] and the
  /// counts and shrunk to [maxLength]. [random] defaults to
  /// [Random.secure]. [MatchRule] is skipped. Throws an [ArgumentError]
  /// when the counts cannot fit in [maxLength] and a [StateError] when a
  /// [CustomRule] rejects every candidate.
  String generate({int length = 16, Random? random}) {
    final source = random ?? Random.secure();
    final required = _requiredCharacters(source);
    var targetLength = max(length, max(minLength, required.length));
    if (maxLength > 0) {
      targetLength = min(targetLength, maxLength);
    }
    if (targetLength < required.length) {
      throw ArgumentError(
        'The rule counts need ${required.length} characters but maxLength is '
        '$maxLength.',
      );
    }
    for (var attempt = 0; attempt < _generateAttempts; attempt++) {
      final characters = [
        ...required,
        for (var index = required.length; index < targetLength; index++)
          _pick(_generatedAny, source),
      ]..shuffle(source);
      final candidate = characters.join();
      if (_acceptsGenerated(candidate)) {
        return candidate;
      }
      required
        ..clear()
        ..addAll(_requiredCharacters(source));
    }
    throw StateError(
      'No generated password satisfied the rules in $_generateAttempts '
      'attempts.',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PasswordRules &&
      other.minLength == minLength &&
      other.maxLength == maxLength &&
      other.letters == letters &&
      other.uppercase == uppercase &&
      other.lowercase == lowercase &&
      other.digits == digits &&
      other.special == special &&
      _listEquals(other.custom, custom);

  @override
  int get hashCode => Object.hash(
    minLength,
    maxLength,
    letters,
    uppercase,
    lowercase,
    digits,
    special,
    Object.hashAll(custom),
  );
}

import 'password_rules.dart';

/// Builds the label of one rule from the count the rule requires.
typedef PasswordRuleLabel = String Function(int count);

/// Builds the label of a strength level.
typedef PasswordStrengthLabel = String Function(PasswordStrength strength);

const String _persianDigitCharacters = '۰۱۲۳۴۵۶۷۸۹';

/// Rewrites the ASCII digits of [count] as Persian digits.
String _persianNumber(int count) => count.toString().replaceAllMapped(
  RegExp(r'[0-9]'),
  (match) => _persianDigitCharacters[int.parse(match[0]!)],
);

String _plural(int count, String singular, String plural) =>
    count == 1 ? singular : plural;

String _englishMinLength(int count) =>
    'At least $count ${_plural(count, 'character', 'characters')}';

String _englishMaxLength(int count) =>
    'At most $count ${_plural(count, 'character', 'characters')}';

String _englishLetters(int count) =>
    '$count ${_plural(count, 'letter', 'letters')}';

String _englishUppercase(int count) =>
    '$count ${_plural(count, 'uppercase letter', 'uppercase letters')}';

String _englishLowercase(int count) =>
    '$count ${_plural(count, 'lowercase letter', 'lowercase letters')}';

String _englishDigits(int count) =>
    '$count ${_plural(count, 'digit', 'digits')}';

String _englishSpecial(int count) =>
    '$count ${_plural(count, 'special character', 'special characters')}';

String _englishStrength(PasswordStrength strength) => switch (strength) {
  PasswordStrength.weak => 'Weak',
  PasswordStrength.fair => 'Fair',
  PasswordStrength.good => 'Good',
  PasswordStrength.strong => 'Strong',
};

String _persianMinLength(int count) => 'حداقل ${_persianNumber(count)} کاراکتر';

String _persianMaxLength(int count) =>
    'حداکثر ${_persianNumber(count)} کاراکتر';

String _persianLetters(int count) => '${_persianNumber(count)} حرف';

String _persianUppercase(int count) => '${_persianNumber(count)} حرف بزرگ';

String _persianLowercase(int count) => '${_persianNumber(count)} حرف کوچک';

String _persianDigits(int count) => '${_persianNumber(count)} رقم';

String _persianSpecial(int count) => '${_persianNumber(count)} کاراکتر خاص';

String _persianStrength(PasswordStrength strength) => switch (strength) {
  PasswordStrength.weak => 'ضعیف',
  PasswordStrength.fair => 'متوسط',
  PasswordStrength.good => 'خوب',
  PasswordStrength.strong => 'قوی',
};

/// The labels of the rules, the strength levels and the rule states.
///
/// Every count rule label is a function of the required count, so a
/// translation can handle plural forms and digit shapes. Labels without an
/// override keep their English text. [PasswordRuleStrings.persian] is a
/// complete Persian set.
///
/// ```dart
/// const german = PasswordRuleStrings(
///   minLength: germanMinLength,
///   digits: germanDigits,
/// );
/// ```
class PasswordRuleStrings {
  /// Creates the labels, in English unless overridden.
  const PasswordRuleStrings({
    this.minLength = _englishMinLength,
    this.maxLength = _englishMaxLength,
    this.letters = _englishLetters,
    this.uppercase = _englishUppercase,
    this.lowercase = _englishLowercase,
    this.digits = _englishDigits,
    this.special = _englishSpecial,
    this.notCommon = 'Not a common password',
    this.passwordsMatch = 'Passwords match',
    this.strength = _englishStrength,
    this.ruleMet = 'met',
    this.ruleNotMet = 'not met',
  });

  /// Creates the labels in Persian, with Persian digits, unless overridden.
  const PasswordRuleStrings.persian({
    this.minLength = _persianMinLength,
    this.maxLength = _persianMaxLength,
    this.letters = _persianLetters,
    this.uppercase = _persianUppercase,
    this.lowercase = _persianLowercase,
    this.digits = _persianDigits,
    this.special = _persianSpecial,
    this.notCommon = 'رمز عبور رایج نباشد',
    this.passwordsMatch = 'رمزهای عبور یکسان باشند',
    this.strength = _persianStrength,
    this.ruleMet = 'رعایت شده',
    this.ruleNotMet = 'رعایت نشده',
  });

  /// Label of [MinLengthRule].
  final PasswordRuleLabel minLength;

  /// Label of [MaxLengthRule].
  final PasswordRuleLabel maxLength;

  /// Label of [LettersRule].
  final PasswordRuleLabel letters;

  /// Label of [UppercaseRule].
  final PasswordRuleLabel uppercase;

  /// Label of [LowercaseRule].
  final PasswordRuleLabel lowercase;

  /// Label of [DigitsRule].
  final PasswordRuleLabel digits;

  /// Label of [SpecialCharactersRule].
  final PasswordRuleLabel special;

  /// Label of [CommonPasswordsRule].
  final String notCommon;

  /// Label of [MatchRule].
  final String passwordsMatch;

  /// Label of each [PasswordStrength] level.
  final PasswordStrengthLabel strength;

  /// Read by screen readers after the label of a passing rule.
  final String ruleMet;

  /// Read by screen readers after the label of a failing rule.
  final String ruleNotMet;

  /// The label of [rule]; a [CustomRule] carries its own.
  String of(PasswordRule rule) => switch (rule) {
    MinLengthRule(:final count) => minLength(count),
    MaxLengthRule(:final count) => maxLength(count),
    LettersRule(:final count) => letters(count),
    UppercaseRule(:final count) => uppercase(count),
    LowercaseRule(:final count) => lowercase(count),
    DigitsRule(:final count) => digits(count),
    SpecialCharactersRule(:final count) => special(count),
    CommonPasswordsRule() => notCommon,
    MatchRule() => passwordsMatch,
    CustomRule(:final label) => label,
  };
}

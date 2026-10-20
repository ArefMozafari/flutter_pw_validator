import 'package:password_rules/password_rules.dart';
import 'package:test/test.dart';

String _persianDigits(int count) => '${count == 2 ? '۲' : count} رقم';

String _persianStrength(PasswordStrength strength) =>
    strength == PasswordStrength.strong ? 'قوی' : 'ضعیف';

bool _hasNoSpaces(String password) => !password.contains(' ');

String _other() => 'other';

void main() {
  group('PasswordRuleStrings.of', () {
    const strings = PasswordRuleStrings();

    test('should describe every rule in English by default', () {
      expect(strings.of(const MinLengthRule(8)), 'At least 8 characters');
      expect(strings.of(const MaxLengthRule(64)), 'At most 64 characters');
      expect(strings.of(const LettersRule(3)), '3 letters');
      expect(strings.of(const UppercaseRule(2)), '2 uppercase letters');
      expect(strings.of(const LowercaseRule(2)), '2 lowercase letters');
      expect(strings.of(const DigitsRule(2)), '2 digits');
      expect(
        strings.of(const SpecialCharactersRule(2)),
        '2 special characters',
      );
      expect(strings.of(const CommonPasswordsRule()), 'Not a common password');
      expect(strings.of(MatchRule(_other)), 'Passwords match');
    });

    test('should use the singular for a count of one', () {
      expect(strings.of(const MinLengthRule(1)), 'At least 1 character');
      expect(strings.of(const MaxLengthRule(1)), 'At most 1 character');
      expect(strings.of(const LettersRule(1)), '1 letter');
      expect(strings.of(const UppercaseRule(1)), '1 uppercase letter');
      expect(strings.of(const LowercaseRule(1)), '1 lowercase letter');
      expect(strings.of(const DigitsRule(1)), '1 digit');
      expect(strings.of(const SpecialCharactersRule(1)), '1 special character');
    });

    test('should return the label of a custom rule as given', () {
      const noSpaces = CustomRule(label: 'No spaces', test: _hasNoSpaces);

      expect(strings.of(noSpaces), 'No spaces');
    });

    test('should use the override for a translated rule only', () {
      const translated = PasswordRuleStrings(digits: _persianDigits);

      expect(translated.of(const DigitsRule(2)), '۲ رقم');
      expect(translated.of(const LettersRule(3)), '3 letters');
    });
  });

  group('PasswordRuleStrings.strength', () {
    test('should name every level in English by default', () {
      const strings = PasswordRuleStrings();

      expect(strings.strength(PasswordStrength.weak), 'Weak');
      expect(strings.strength(PasswordStrength.fair), 'Fair');
      expect(strings.strength(PasswordStrength.good), 'Good');
      expect(strings.strength(PasswordStrength.strong), 'Strong');
    });

    test('should use the override', () {
      const translated = PasswordRuleStrings(strength: _persianStrength);

      expect(translated.strength(PasswordStrength.strong), 'قوی');
    });
  });

  group('PasswordRuleStrings status', () {
    test('should describe a met and an unmet rule in English by default', () {
      const strings = PasswordRuleStrings();

      expect(strings.ruleMet, 'met');
      expect(strings.ruleNotMet, 'not met');
    });
  });

  group('PasswordRuleStrings.persian', () {
    const strings = PasswordRuleStrings.persian();

    test('should describe every rule in Persian with Persian digits', () {
      expect(strings.of(const MinLengthRule(8)), 'حداقل ۸ کاراکتر');
      expect(strings.of(const MaxLengthRule(64)), 'حداکثر ۶۴ کاراکتر');
      expect(strings.of(const LettersRule(3)), '۳ حرف');
      expect(strings.of(const UppercaseRule(2)), '۲ حرف بزرگ');
      expect(strings.of(const LowercaseRule(2)), '۲ حرف کوچک');
      expect(strings.of(const DigitsRule(1)), '۱ رقم');
      expect(strings.of(const SpecialCharactersRule(1)), '۱ کاراکتر خاص');
      expect(strings.of(const CommonPasswordsRule()), 'رمز عبور رایج نباشد');
      expect(strings.of(MatchRule(_other)), 'رمزهای عبور یکسان باشند');
    });

    test('should name every strength level in Persian', () {
      expect(strings.strength(PasswordStrength.weak), 'ضعیف');
      expect(strings.strength(PasswordStrength.fair), 'متوسط');
      expect(strings.strength(PasswordStrength.good), 'خوب');
      expect(strings.strength(PasswordStrength.strong), 'قوی');
    });

    test('should describe a met and an unmet rule in Persian', () {
      expect(strings.ruleMet, 'رعایت شده');
      expect(strings.ruleNotMet, 'رعایت نشده');
    });
  });
}

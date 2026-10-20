import 'dart:math';

import 'package:characters/characters.dart';
import 'package:password_rules/password_rules.dart';
import 'package:test/test.dart';

bool _hasNoSpaces(String password) => !password.contains(' ');

bool _never(String password) => false;

void main() {
  group('PasswordRules.active', () {
    test('should list only the rules above zero, in display order', () {
      const rules = PasswordRules(minLength: 8, digits: 1, uppercase: 2);

      expect(rules.active, const [
        MinLengthRule(8),
        UppercaseRule(2),
        DigitsRule(1),
      ]);
    });

    test('should list custom rules after the built-in ones', () {
      const noSpaces = CustomRule(label: 'No spaces', test: _hasNoSpaces);
      const rules = PasswordRules(maxLength: 64, custom: [noSpaces]);

      expect(rules.active, const [MaxLengthRule(64), noSpaces]);
    });

    test('should be empty when every rule is zero', () {
      expect(const PasswordRules().active, isEmpty);
    });
  });

  group('PasswordRules.nist', () {
    test(
      'should require 15 characters, allow 64 and block common passwords',
      () {
        const rules = PasswordRules.nist();

        expect(rules.active, const [
          MinLengthRule(15),
          MaxLengthRule(64),
          CommonPasswordsRule(),
        ]);
      },
    );

    test('should require 8 characters next to a second factor', () {
      const rules = PasswordRules.nist(multiFactor: true);

      expect(rules.active.first, const MinLengthRule(8));
    });
  });

  group('PasswordRules.validate', () {
    test('should pass minLength at exactly the required length', () {
      const rules = PasswordRules(minLength: 4);

      expect(rules.validate('abcd').isValid, isTrue);
      expect(rules.validate('abc').isValid, isFalse);
    });

    test('should pass maxLength at exactly the allowed length', () {
      const rules = PasswordRules(maxLength: 4);

      expect(rules.validate('').isValid, isTrue);
      expect(rules.validate('abcd').isValid, isTrue);
      expect(rules.validate('abcde').isValid, isFalse);
    });

    test('should count user-perceived characters for minLength', () {
      const rules = PasswordRules(minLength: 2);

      expect(rules.validate('👨‍👩‍👧é').isValid, isTrue);
      expect(rules.validate('👨‍👩‍👧').isValid, isFalse);
    });

    test('should count letters from any script', () {
      const rules = PasswordRules(letters: 3);

      expect(rules.validate('aÉб').isValid, isTrue);
      expect(rules.validate('سلام').isValid, isTrue);
      expect(rules.validate('a1!').isValid, isFalse);
    });

    test('should count uppercase letters beyond ASCII', () {
      const rules = PasswordRules(uppercase: 2);

      expect(rules.validate('aÉB').isValid, isTrue);
      expect(rules.validate('aéb').isValid, isFalse);
    });

    test('should count lowercase letters beyond ASCII', () {
      const rules = PasswordRules(lowercase: 2);

      expect(rules.validate('Aéb').isValid, isTrue);
      expect(rules.validate('AÉB').isValid, isFalse);
    });

    test('should count decimal digits from any script', () {
      const rules = PasswordRules(digits: 2);

      expect(rules.validate('a1۲').isValid, isTrue);
      expect(rules.validate('a1').isValid, isFalse);
    });

    test('should count punctuation and symbols as special characters', () {
      const rules = PasswordRules(special: 3);

      expect(rules.validate('a_b€c!').isValid, isTrue);
      expect(rules.validate('a_b').isValid, isFalse);
    });

    test('should not count whitespace or combining marks as special', () {
      const rules = PasswordRules(special: 1);

      expect(rules.validate('a b\tc').isValid, isFalse);
      expect(rules.validate('é').isValid, isFalse);
    });

    test('should run a custom rule against the password', () {
      const noSpaces = CustomRule(label: 'No spaces', test: _hasNoSpaces);
      const rules = PasswordRules(custom: [noSpaces]);

      expect(rules.validate('abc').results, {noSpaces: true});
      expect(rules.validate('a bc').results, {noSpaces: false});
    });

    test('should report one result per active rule', () {
      const rules = PasswordRules(minLength: 6, uppercase: 1, digits: 1);

      final validation = rules.validate('abcdef1');

      expect(validation.results, {
        const MinLengthRule(6): true,
        const UppercaseRule(1): false,
        const DigitsRule(1): true,
      });
      expect(validation.isValid, isFalse);
      expect(validation.failed, const [UppercaseRule(1)]);
    });

    test('should be valid when no rule is active', () {
      expect(const PasswordRules().validate('').isValid, isTrue);
    });
  });

  group('CommonPasswordsRule', () {
    const rule = CommonPasswordsRule();

    test('should fail a password from the top-1000 list, ignoring case', () {
      expect(rule.test('password'), isFalse);
      expect(rule.test('PASSWORD'), isFalse);
      expect(rule.test('123456'), isFalse);
      expect(rule.test('qwerty'), isFalse);
    });

    test('should pass a password that is not on the list', () {
      expect(rule.test('correct horse battery staple'), isTrue);
      expect(rule.test(''), isTrue);
    });

    test('should be equal to another instance', () {
      expect(rule, const CommonPasswordsRule());
      expect(rule.hashCode, const CommonPasswordsRule().hashCode);
    });
  });

  group('MatchRule', () {
    test('should pass only while the password equals the other value', () {
      var other = 'secret';
      final rule = MatchRule(() => other);

      expect(rule.test('secret'), isTrue);

      other = 'changed';

      expect(rule.test('secret'), isFalse);
    });
  });

  group('PasswordRules.formValidator', () {
    const rules = PasswordRules(minLength: 8, digits: 1);

    test('should return null for a valid password', () {
      expect(rules.formValidator()('abcdefg1'), isNull);
    });

    test('should join the failing labels', () {
      expect(rules.formValidator()('abc'), 'At least 8 characters, 1 digit');
    });

    test('should treat null as an empty password', () {
      expect(rules.formValidator()(null), 'At least 8 characters, 1 digit');
    });

    test('should use the given strings and separator', () {
      final validator = rules.formValidator(
        strings: const PasswordRuleStrings.persian(),
        separator: '، ',
      );

      expect(validator('abc'), 'حداقل ۸ کاراکتر، ۱ رقم');
    });
  });

  group('PasswordRules.generate', () {
    const rules = PasswordRules(
      minLength: 8,
      uppercase: 1,
      lowercase: 1,
      digits: 1,
      special: 1,
      custom: [CustomRule(label: 'No spaces', test: _hasNoSpaces)],
    );

    test('should satisfy every active rule', () {
      for (var attempt = 0; attempt < 50; attempt++) {
        final password = rules.generate();

        expect(rules.validate(password).isValid, isTrue, reason: password);
      }
    });

    test('should have the requested length', () {
      expect(rules.generate(length: 20).characters.length, 20);
      expect(rules.generate(length: 20), isNot(rules.generate(length: 20)));
    });

    test('should grow to fit the counts and the minimum length', () {
      expect(
        const PasswordRules(digits: 10).generate(length: 4).characters.length,
        10,
      );
      expect(
        const PasswordRules(
          minLength: 12,
        ).generate(length: 4).characters.length,
        12,
      );
    });

    test('should shrink to the maximum length', () {
      expect(
        const PasswordRules(
          maxLength: 10,
        ).generate(length: 20).characters.length,
        10,
      );
    });

    test('should count letters across both cases', () {
      final password = const PasswordRules(
        letters: 3,
        uppercase: 1,
      ).generate(length: 3);

      expect(password.characters.length, 3);
      expect(
        const PasswordRules(letters: 3).validate(password).isValid,
        isTrue,
      );
    });

    test('should ignore a MatchRule', () {
      final withMatch = PasswordRules(custom: [MatchRule(() => 'other')]);

      expect(withMatch.generate().characters.length, 16);
    });

    test('should be reproducible with the same random source', () {
      expect(
        rules.generate(random: Random(7)),
        rules.generate(random: Random(7)),
      );
    });

    test('should throw when the counts exceed the maximum length', () {
      const impossible = PasswordRules(maxLength: 2, digits: 3);

      expect(impossible.generate, throwsArgumentError);
    });

    test('should throw when a custom rule never passes', () {
      const impossible = PasswordRules(
        custom: [CustomRule(label: 'Never', test: _never)],
      );

      expect(impossible.generate, throwsStateError);
    });
  });

  group('PasswordValidation.score', () {
    test('should be the share of passing rules', () {
      const rules = PasswordRules(minLength: 8, uppercase: 1, digits: 1);

      expect(rules.validate('').score, 0);
      expect(rules.validate('a1').score, closeTo(1 / 3, 0.0001));
      expect(rules.validate('abcdefg1').score, closeTo(2 / 3, 0.0001));
      expect(rules.validate('Abcdefg1').score, 1);
    });

    test('should be one when no rule is active', () {
      expect(const PasswordRules().validate('').score, 1);
    });
  });

  group('PasswordValidation.strength', () {
    const rules = PasswordRules(
      minLength: 8,
      uppercase: 1,
      lowercase: 1,
      digits: 1,
      special: 1,
    );

    test('should be weak below half of the rules', () {
      expect(rules.validate('').strength, PasswordStrength.weak);
      expect(rules.validate('a').strength, PasswordStrength.weak);
      expect(rules.validate('a1').strength, PasswordStrength.weak);
    });

    test('should be fair from half of the rules', () {
      expect(rules.validate('aB1').strength, PasswordStrength.fair);
      expect(
        const PasswordRules(minLength: 8, digits: 1).validate('1').strength,
        PasswordStrength.fair,
      );
    });

    test('should be good from three quarters of the rules', () {
      expect(rules.validate('aB1!').strength, PasswordStrength.good);
    });

    test('should be strong when every rule passes', () {
      expect(rules.validate('aB1!efgh').strength, PasswordStrength.strong);
      expect(
        const PasswordRules().validate('').strength,
        PasswordStrength.strong,
      );
    });
  });

  group('PasswordRules', () {
    test('should reject a negative count', () {
      const count = -1;

      expect(
        () => PasswordRules(minLength: count),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should be equal to rules with the same counts and custom rules', () {
      const noSpaces = CustomRule(label: 'No spaces', test: _hasNoSpaces);

      expect(
        const PasswordRules(minLength: 8, digits: 1, custom: [noSpaces]),
        const PasswordRules(minLength: 8, digits: 1, custom: [noSpaces]),
      );
      expect(
        const PasswordRules(minLength: 8, digits: 1),
        isNot(const PasswordRules(minLength: 8, digits: 2)),
      );
      expect(
        const PasswordRules(minLength: 8, custom: [noSpaces]),
        isNot(const PasswordRules(minLength: 8)),
      );
    });
  });

  group('CountRule', () {
    test('should be equal to the same rule with the same count', () {
      expect(const MinLengthRule(8), const MinLengthRule(8));
      expect(const MinLengthRule(8), isNot(const MinLengthRule(9)));
      expect(const MinLengthRule(8), isNot(const MaxLengthRule(8)));
    });

    test('should reject a count of zero', () {
      const count = 0;

      expect(() => DigitsRule(count), throwsA(isA<AssertionError>()));
    });
  });

  group('PasswordRule.toString', () {
    test('should name the rule and its count or label', () {
      expect(const MinLengthRule(8).toString(), 'MinLengthRule(8)');
      expect(const CommonPasswordsRule().toString(), 'CommonPasswordsRule');
      expect(MatchRule(() => '').toString(), 'MatchRule');
      expect(
        const CustomRule(label: 'No spaces', test: _hasNoSpaces).toString(),
        'CustomRule(No spaces)',
      );
    });
  });
}

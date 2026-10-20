import 'package:password_rules/password_rules.dart';

bool _hasNoSpaces(String password) => !password.contains(' ');

void main() {
  const rules = PasswordRules(
    minLength: 8,
    uppercase: 1,
    digits: 1,
    custom: [
      CustomRule(label: 'No spaces', test: _hasNoSpaces),
      CommonPasswordsRule(),
    ],
  );
  const strings = PasswordRuleStrings();

  final validation = rules.validate('password');
  print('valid: ${validation.isValid}, strength: ${validation.strength}');
  for (final rule in validation.failed) {
    print('unmet: ${strings.of(rule)}');
  }

  print('suggestion: ${rules.generate()}');
  print('NIST policy: ${const PasswordRules.nist().active}');
}

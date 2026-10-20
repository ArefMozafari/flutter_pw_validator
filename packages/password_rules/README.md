# password_rules

Password policy as a plain Dart value. The same `PasswordRules` drives the
[`flutter_pw_validator`](https://pub.dev/packages/flutter_pw_validator) widget
in the app and the check in your Dart backend, so the two never disagree.

## Use

```dart
import 'package:password_rules/password_rules.dart';

const rules = PasswordRules(minLength: 8, uppercase: 1, digits: 1);

final validation = rules.validate(password);
validation.isValid;   // every rule passes
validation.failed;    // the rules that did not, in display order
validation.score;     // passing rules over active rules, 0.0 to 1.0
validation.strength;  // weak, fair, good or strong
```

In a shelf, Dart Frog or Serverpod handler:

```dart
final validation = rules.validate(body['password'] as String);
if (!validation.isValid) {
  final strings = const PasswordRuleStrings();
  return Response.badRequest(
    body: validation.failed.map(strings.of).join(', '),
  );
}
```

## Rules

| Parameter | Counts |
|-----------|--------|
| `minLength` | user-perceived characters, so an emoji sequence counts once |
| `maxLength` | the same, as an upper bound |
| `letters` | letters from any script |
| `uppercase` | uppercase letters |
| `lowercase` | lowercase letters |
| `digits` | decimal digits from any script |
| `special` | anything that is not a letter, mark, number or whitespace |
| `custom` | further rules, checked after the counts |

A count of zero disables the rule. Each active rule is a `PasswordRule`
object: `MinLengthRule(8)`, `DigitsRule(1)` and so on, with value equality.

`custom` takes any `PasswordRule`:

- `CustomRule(label: 'No spaces', test: hasNoSpaces)` wraps a predicate; the
  label is shown as given.
- `CommonPasswordsRule()` rejects the thousand most common leaked passwords,
  case-insensitively. The list comes from
  [SecLists](https://github.com/danielmiessler/SecLists) (MIT) and is
  regenerated with `tool/generate_common_passwords.dart`.
- `MatchRule(() => confirmField.text)` passes while the password equals the
  value the getter returns.

### NIST preset

`PasswordRules.nist()` is the policy of NIST SP 800-63B-4: at least 15
characters, or 8 with `multiFactor: true`, at most 64, no composition rules,
and the common-password blocklist.

## Generate

`rules.generate()` returns a random ASCII password that passes every active
rule, 16 characters unless the rules need more or `maxLength` allows fewer.
`MatchRule` is skipped. Pass `random` to make it reproducible in tests.

## Form validator

`rules.formValidator()` returns a `String? Function(String?)` for a Flutter
`TextFormField`: null when valid, otherwise the failing labels joined by
`separator`.

## Strings

`PasswordRuleStrings` holds the labels. Each count label is a function of the
count, so plurals and digit shapes are yours. `PasswordRuleStrings.persian()`
ships complete, with Persian digits.

## License

[MIT](LICENSE)

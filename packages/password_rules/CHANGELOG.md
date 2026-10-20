## 1.0.0

* First release, extracted from `flutter_pw_validator` so a Dart backend can
  enforce the same policy as the app.
* `PasswordRules` with `minLength`, `maxLength`, `letters`, `uppercase`,
  `lowercase`, `digits`, `special` and `custom`; Unicode-aware counting.
* `PasswordRule` subclasses with value equality, `CustomRule`,
  `CommonPasswordsRule` over the SecLists top-1000 list, and `MatchRule`.
* `PasswordRules.nist()` for NIST SP 800-63B-4.
* `validate()` returning `results`, `isValid`, `failed`, `score` and
  `strength`; `formValidator()`; `generate()`.
* `PasswordRuleStrings` in English and Persian.

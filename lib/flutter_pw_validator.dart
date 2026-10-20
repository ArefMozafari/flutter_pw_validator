/// Live password rules under any TextField: a progress bar and a checklist of
/// the rules still unmet.
///
/// The rules themselves come from `package:password_rules`, re-exported here,
/// so a Dart backend can enforce the same policy.
library;

export 'package:password_rules/password_rules.dart';

export 'src/flutter_pw_validator.dart';

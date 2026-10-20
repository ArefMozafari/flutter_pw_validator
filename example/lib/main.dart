import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

void main() => runApp(const ExampleApp());

/// Shows a password field with the validator under it, a confirmation field,
/// a button that fills both with a generated password, and a submit button
/// that is enabled only while every rule passes.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'flutter_pw_validator',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    ),
    home: const SignUpPage(),
  );
}

/// The one screen of the example.
class SignUpPage extends StatefulWidget {
  /// Creates the sign-up screen.
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const double _pagePadding = 24;
  static const double _fieldGap = 12;
  static const double _buttonGap = 32;

  static bool _hasNoSpaces(String password) => !password.contains(' ');

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FlutterPwValidatorState> _validatorKey =
      GlobalKey<FlutterPwValidatorState>();
  late final PasswordRules _rules = PasswordRules(
    minLength: 8,
    uppercase: 1,
    lowercase: 1,
    digits: 1,
    special: 1,
    custom: [
      const CustomRule(label: 'No spaces', test: _hasNoSpaces),
      MatchRule(() => _confirmController.text),
    ],
  );
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _suggest() {
    final password = _rules.generate();
    _confirmController.text = password;
    _controller.text = password;
  }

  void _submit() {
    final isValid = _validatorKey.currentState!.validate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isValid ? 'Password accepted' : 'Password rejected'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('flutter_pw_validator')),
    body: ListView(
      padding: const EdgeInsets.all(_pagePadding),
      children: [
        TextField(
          controller: _controller,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: _fieldGap),
        FlutterPwValidator(
          key: _validatorKey,
          controller: _controller,
          rules: _rules,
          listenables: [_confirmController],
          showStrengthLabel: true,
          onChanged: (validation) =>
              setState(() => _isValid = validation.isValid),
        ),
        const SizedBox(height: _fieldGap),
        TextField(
          controller: _confirmController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: _buttonGap),
        TextButton(
          onPressed: _suggest,
          child: const Text('Suggest a strong password'),
        ),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}

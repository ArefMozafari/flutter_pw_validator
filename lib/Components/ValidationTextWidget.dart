import 'package:flutter/material.dart';

/// ValidationTextWidget that represent style of each one of them and shows as list of condition that you want to the app user
class ValidationTextWidget extends StatelessWidget {
  final bool? success;
  final Color defaultColor;
  final Color successColor;
  final Color failureColor;
  final String text;
  final int? value;
  final TextStyle? textStyle;

  ValidationTextWidget({
    required this.success,
    required this.text,
    required this.value,
    required this.defaultColor,
    required this.successColor,
    required this.failureColor,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    Color color = success == null ? defaultColor : success! ? successColor : failureColor;
    return Row(
      children: [
        Icon(
          success == null || success! ? Icons.check : Icons.close,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 10),
        Text(
          text.replaceFirst("-", value.toString()),
          style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: color)
        )
      ],
    );
  }
}

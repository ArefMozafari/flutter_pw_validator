import 'package:flutter/material.dart';

/// ValidationTextWidget that represent style of each one of them and shows as list of condition that you want to the app user
class ValidationTextWidget extends StatelessWidget {
  final Color color;
  final String text;
  final int? value;
  final TextStyle? textStyle;

  ValidationTextWidget({
    required this.color,
    required this.text,
    required this.value,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        new CircleAvatar(
          backgroundColor: color,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: new Text(
            text.replaceFirst("-", value.toString()),
            style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: color)
          ),
        )
      ],
    );
  }
}

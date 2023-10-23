import 'package:flutter/material.dart';

/// ValidationBarWidget that represent style of each one of them and shows under the TextField
class ValidationBarComponent extends StatelessWidget {
  final Color color;
  final double? thickness;

  ValidationBarComponent({
    required this.color,
    this.thickness
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: new Container(
        /// We Can set, width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 2),
        height: thickness ?? 4,
        decoration: new BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
    );
  }
}

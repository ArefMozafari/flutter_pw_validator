import 'package:flutter/material.dart';
import 'file:///D:/Projects/Main%20Projects/flutter_pw_validator/lib/Utilities/SizeConfig.dart';

class ValidationBarComponent extends StatelessWidget {
  final Color color;

  ValidationBarComponent({@required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: new Container(
        // width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.005),
        height: SizeConfig.width * 0.015,
        decoration: new BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(SizeConfig.width))),
      ),
    );
  }
}

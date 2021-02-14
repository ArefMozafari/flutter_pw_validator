import 'package:flutter/material.dart';
import 'file:///D:/Projects/Main%20Projects/flutter_pw_validator/lib/Utilities/SizeConfig.dart';


class ValidationTextWidget extends StatelessWidget {
  final Color color;
  final String text;

  ValidationTextWidget({@required this.color, @required this.text});

  @override
  Widget build(BuildContext context) {

    return new Row(
      children: [
        new Container(
          width: SizeConfig.width * 0.03,
          height: SizeConfig.width * 0.03,
          child: new CircleAvatar(
            backgroundColor: color,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.width * 0.03),
          child: new Text(text, style: new TextStyle(fontSize: SizeConfig.width * 0.04,color: color),),
        )
      ],
    );
  }
}

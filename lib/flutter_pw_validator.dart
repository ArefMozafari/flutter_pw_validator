library flutter_pw_validator;

import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_pw_validator/Utilities/PasswordValidation.dart';
import 'Components/ValidationBarWidget.dart';
import 'Components/ValidationTextWidget.dart';
import 'Utilities/SizeConfig.dart';
import 'Resource/Strings.dart';
import 'Resource/MyColors.dart';

class FlutterPwValidator extends StatefulWidget {
  final int minLength, uppercaseCharCount, numericCharCount, specialCharCount;
  final Color defaultColor, successColor, failureColor;
  final double width, height;
  final Function onSuccess;
  final TextEditingController controller;

  FlutterPwValidator(
      {@required this.width,
      @required this.height,
      @required this.minLength,
      @required this.onSuccess,
      @required this.controller,
      this.uppercaseCharCount = 0,
      this.numericCharCount = 0,
      this.specialCharCount = 0,
      this.defaultColor = MyColors.gray,
      this.successColor = MyColors.green,
      this.failureColor = MyColors.red}) {
    SizeConfig.width = width;
    SizeConfig.height = height;
  }

  @override
  State<StatefulWidget> createState() => new _FlutterPwValidatorState();
}

class _FlutterPwValidatorState extends State<FlutterPwValidator> {
  bool isFirstRun;
  bool hasMinLength, hasMinUppercaseChar, hasMinNumericChar, hasMinSpecialChar;
  // ConditionsHelper conditionsHelper;
  Map<String,bool> conditions;

  void validate() {

    if (widget.minLength > 0) {
      hasMinLength = PasswordValidation.hasMinLength(
          widget.controller.text, widget.minLength);
      if (conditions[Strings.AT_LEAST] != hasMinLength) conditions[Strings.AT_LEAST] = hasMinLength;
    }

    if (widget.uppercaseCharCount > 0) {
      hasMinUppercaseChar = PasswordValidation.hasMinUppercase(
          widget.controller.text, widget.uppercaseCharCount);
      if (conditions[Strings.UPPERCASE_LETTER] != hasMinUppercaseChar) conditions[Strings.UPPERCASE_LETTER] = hasMinUppercaseChar;
    }

    if (widget.numericCharCount > 0) {
      hasMinNumericChar = PasswordValidation.hasMinNumericChar(
          widget.controller.text, widget.numericCharCount);
      if (conditions[Strings.NUMERIC_CHARACTER] != hasMinNumericChar) conditions[Strings.NUMERIC_CHARACTER] = hasMinNumericChar;
    }

    if (widget.specialCharCount > 0) {
      hasMinSpecialChar = PasswordValidation.hasMinSpecialChar(
          widget.controller.text, widget.specialCharCount);
      if (conditions[Strings.SPECIAL_CHARACTER] != hasMinSpecialChar) conditions[Strings.SPECIAL_CHARACTER] = hasMinSpecialChar;
    }

    // if (hasMinLength &&
    //     hasMinUppercaseChar &&
    //     hasMinNumericChar &&
    //     hasMinSpecialChar) widget.onSuccess();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isFirstRun = true;


    conditions = {
      if(widget.minLength >0) Strings.AT_LEAST : false,
      if(widget.uppercaseCharCount >0) Strings.UPPERCASE_LETTER : false,
      if(widget.numericCharCount >0) Strings.NUMERIC_CHARACTER : false,
      if(widget.specialCharCount >0) Strings.SPECIAL_CHARACTER : false
    };

    widget.controller.addListener(() {
      isFirstRun = false;
      validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: SizeConfig.width,
      height: widget.height,
      // color: MyColors.green,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Flexible(
            flex: 3,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                for (bool condition in conditions.values)
                  if (condition == true ) new ValidationBarComponent(color: widget.successColor),
                for (bool condition in conditions.values)
                  if (condition == false ) new ValidationBarComponent(color: widget.defaultColor)
              ],
            ),
          ),
          // new Flexible(flex: 1, child: new Container()),
          new Flexible(
            flex: 7,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.minLength > 0)
                  new ValidationTextWidget(
                      color: isFirstRun
                          ? widget.defaultColor
                          : hasMinLength
                              ? widget.successColor
                              : widget.failureColor,
                      text: Strings.AT_LEAST
                          .replaceFirst("-", widget.minLength.toString())),
                if (widget.uppercaseCharCount > 0)
                  new ValidationTextWidget(
                      color: isFirstRun
                          ? widget.defaultColor
                          : hasMinUppercaseChar
                              ? widget.successColor
                              : widget.failureColor,
                      text: Strings.UPPERCASE_LETTER.replaceFirst(
                          "-", widget.uppercaseCharCount.toString())),
                if (widget.numericCharCount > 0)
                  new ValidationTextWidget(
                      color: isFirstRun
                          ? widget.defaultColor
                          : hasMinNumericChar
                              ? widget.successColor
                              : widget.failureColor,
                      text: Strings.NUMERIC_CHARACTER.replaceFirst(
                          "-", widget.numericCharCount.toString())),
                if (widget.specialCharCount > 0)
                  new ValidationTextWidget(
                      color: isFirstRun
                          ? widget.defaultColor
                          : hasMinSpecialChar
                              ? widget.successColor
                              : widget.failureColor,
                      text: Strings.SPECIAL_CHARACTER.replaceFirst(
                          "-", widget.specialCharCount.toString())),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

library flutter_pw_validator;

import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_pw_validator/Utilities/Validator.dart';

import 'Components/ValidationBarWidget.dart';
import 'Components/ValidationTextWidget.dart';
import 'Resource/MyColors.dart';
import 'Resource/Strings.dart';
import 'Utilities/SizeConfig.dart';

class FlutterPwValidator extends StatefulWidget {
  final int minLength,
      normalCharCount,
      uppercaseCharCount,
      numericCharCount,
      specialCharCount;
  final Color defaultColor, successColor, failureColor;
  final double width, height;
  final Function onSuccess;
  final Function? onFail;
  final TextEditingController controller;
  final FlutterPwValidatorStrings? strings;

  FlutterPwValidator(
      {required this.width,
      required this.height,
      required this.minLength,
      required this.onSuccess,
      required this.controller,
      this.uppercaseCharCount = 0,
      this.numericCharCount = 0,
      this.specialCharCount = 0,
      this.normalCharCount = 0,
      this.defaultColor = MyColors.gray,
      this.successColor = MyColors.green,
      this.failureColor = MyColors.red,
      this.strings,
      this.onFail}) {
    //Initial entered size for global use
    SizeConfig.width = width;
    SizeConfig.height = height;
  }

  @override
  State<StatefulWidget> createState() => new _FlutterPwValidatorState();

  FlutterPwValidatorStrings get translatedStrings =>
      this.strings ?? FlutterPwValidatorStrings();
}

class _FlutterPwValidatorState extends State<FlutterPwValidator> {
  /// Estimate that this the first run or not
  late bool isFirstRun;

  /// Variables that hold current condition states
  dynamic hasMinLength,
      hasMinNormalChar,
      hasMinUppercaseChar,
      hasMinNumericChar,
      hasMinSpecialChar;

  //Initial instances of ConditionHelper and Validator class
  late final ConditionsHelper conditionsHelper;
  Validator validator = new Validator();

  /// Get called each time that user entered a character in EditText
  void validate() {
    /// For each condition we called validators and get their new state
    hasMinLength = conditionsHelper.checkCondition(
        widget.minLength,
        validator.hasMinLength,
        widget.controller,
        widget.translatedStrings.atLeast,
        hasMinLength);

    hasMinNormalChar = conditionsHelper.checkCondition(
        widget.normalCharCount,
        validator.hasMinNormalChar,
        widget.controller,
        widget.translatedStrings.normalLetters,
        hasMinNormalChar);

    hasMinUppercaseChar = conditionsHelper.checkCondition(
        widget.uppercaseCharCount,
        validator.hasMinUppercase,
        widget.controller,
        widget.translatedStrings.uppercaseLetters,
        hasMinUppercaseChar);

    hasMinNumericChar = conditionsHelper.checkCondition(
        widget.numericCharCount,
        validator.hasMinNumericChar,
        widget.controller,
        widget.translatedStrings.numericCharacters,
        hasMinNumericChar);

    hasMinSpecialChar = conditionsHelper.checkCondition(
        widget.specialCharCount,
        validator.hasMinSpecialChar,
        widget.controller,
        widget.translatedStrings.specialCharacters,
        hasMinSpecialChar);

    /// Checks if all condition are true then call the onSuccess and if not, calls onFail method
    int conditionsCount = conditionsHelper.getter()!.length;
    int trueCondition = 0;
    for (bool value in conditionsHelper.getter()!.values) {
      if (value == true) trueCondition += 1;
    }
    if (conditionsCount == trueCondition)
      widget.onSuccess();
    else if (widget.onFail != null) widget.onFail!();

    //Rebuild the UI
    setState(() => null);
    trueCondition = 0;
  }

  @override
  void initState() {
    super.initState();
    isFirstRun = true;

    conditionsHelper = ConditionsHelper(widget.translatedStrings);

    /// Sets user entered value for each condition
    conditionsHelper.setSelectedCondition(
        widget.minLength,
        widget.normalCharCount,
        widget.uppercaseCharCount,
        widget.numericCharCount,
        widget.specialCharCount);

    /// Adds a listener callback on TextField to run after input get changed
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
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Flexible(
            flex: 3,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Iterate through the conditions map values to check if there is any true values then create green ValidationBarComponent.
                for (bool value in conditionsHelper.getter()!.values)
                  if (value == true)
                    new ValidationBarComponent(color: widget.successColor),

                // Iterate through the conditions map values to check if there is any false values then create red ValidationBarComponent.
                for (bool value in conditionsHelper.getter()!.values)
                  if (value == false)
                    new ValidationBarComponent(color: widget.defaultColor)
              ],
            ),
          ),
          new Flexible(
            flex: 7,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                //Iterate through the condition map entries and generate new ValidationTextWidget for each item in Green or Red Color
                children: conditionsHelper.getter()!.entries.map((entry) {
                  int? value;
                  if (entry.key == widget.translatedStrings.atLeast)
                    value = widget.minLength;
                  if (entry.key == widget.translatedStrings.normalLetters)
                    value = widget.normalCharCount;
                  if (entry.key == widget.translatedStrings.uppercaseLetters)
                    value = widget.uppercaseCharCount;
                  if (entry.key == widget.translatedStrings.numericCharacters)
                    value = widget.numericCharCount;
                  if (entry.key == widget.translatedStrings.specialCharacters)
                    value = widget.specialCharCount;
                  return new ValidationTextWidget(
                    color: isFirstRun
                        ? widget.defaultColor
                        : entry.value
                            ? widget.successColor
                            : widget.failureColor,
                    text: entry.key,
                    value: value,
                  );
                }).toList()),
          )
        ],
      ),
    );
  }
}

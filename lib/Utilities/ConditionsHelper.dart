import 'package:flutter_pw_validator/Resource/Strings.dart';

class ConditionsHelper {

  Map<String,bool> getSelectedCondition(int minLength, uppercaseCharCount, numericCharCount, specialCharCount) {
    return {
      if(minLength >0) Strings.AT_LEAST : false,
      if(uppercaseCharCount >0) Strings.UPPERCASE_LETTER : false,
      if(numericCharCount >0) Strings.NUMERIC_CHARACTER : false,
      if(specialCharCount >0) Strings.SPECIAL_CHARACTER : false
    };
  }

  bool checkCondition(){

  }
}
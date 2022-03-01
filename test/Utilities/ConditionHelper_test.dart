import 'package:flutter_pw_validator/Resource/Strings.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Tests for setSelectedCondition() component", () {
    late ConditionsHelper conditionsHelper;

    setUp(() {
      conditionsHelper = new ConditionsHelper(FlutterPwValidatorStrings());
    });

    test('Should _selectedCondition.length==3 when we have 3 condition > 0',
        () {
      // arrange
      int minLength = 10;
      int normalCharCount = 1;
      int uppercaseCharCount = 0;
      int numericCharCount = 1;
      int specialCharCount = 0;

      int expectedResult = 3;

      // act
      conditionsHelper.setSelectedCondition(minLength, normalCharCount,
          uppercaseCharCount, numericCharCount, specialCharCount);
      int actualResult = conditionsHelper.getter()!.length;

      // assert
      expect(actualResult, expectedResult);
    });

    test('Should _selectedCondition.length==5 when we have 5 condition > 0',
        () {
      // arrange
      int minLength = 10;
      int normalCharCount = 3;
      int uppercaseCharCount = 2;
      int numericCharCount = 2;
      int specialCharCount = 2;

      int expectedResult = 5;

      // act
      conditionsHelper.setSelectedCondition(minLength, normalCharCount,
          uppercaseCharCount, numericCharCount, specialCharCount);
      int actualResult = conditionsHelper.getter()!.length;

      // assert
      expect(actualResult, expectedResult);
    });
  });
}

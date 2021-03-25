import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';

void main() {
  group("Tests for setSelectedCondition() component", () {
    late ConditionsHelper conditionsHelper;

    setUp(() {
      conditionsHelper = new ConditionsHelper();
    });

    test('Should _selectedCondition.length==2 when we have 2 condition > 0',
        () {
      // arrange
      int minLength = 10;
      int uppercaseCharCount = 0;
      int numericCharCount = 1;
      int specialCharCount = 0;

      int expectedResult = 2;

      // act
      conditionsHelper.setSelectedCondition(
          minLength, uppercaseCharCount, numericCharCount, specialCharCount);
      int actualResult = conditionsHelper.getter()!.length;

      // assert
      expect(actualResult, expectedResult);
    });

    test('Should _selectedCondition.length==4 when we have 4 condition > 0',
        () {
      // arrange
      int minLength = 10;
      int uppercaseCharCount = 2;
      int numericCharCount = 2;
      int specialCharCount = 2;

      int expectedResult = 4;

      // act
      conditionsHelper.setSelectedCondition(
          minLength, uppercaseCharCount, numericCharCount, specialCharCount);
      int actualResult = conditionsHelper.getter()!.length;

      // assert
      expect(actualResult, expectedResult);
    });
  });
}

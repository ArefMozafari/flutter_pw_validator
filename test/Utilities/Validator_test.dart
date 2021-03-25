import 'package:flutter_pw_validator/Utilities/Validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Tests for hasMinLength() component", () {
    late Validator validator;

    setUp(() {
      validator = new Validator();
    });

    test(
        'Should return True when minLength is 10 and password has 10 character',
        () {
      // arrange
      String password = "djgmksoldq";
      int minLength = 10;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinLength(password, minLength);

      // assert
      expect(actualResult, expectedResult);
    });

    test(
        'Should return False when minLength is 10 and password has 5 character',
        () {
      // arrange
      String password = "ksorn";
      int minLength = 10;
      bool expectedResult = false;

      // act
      bool actualResult = validator.hasMinLength(password, minLength);

      // assert
      expect(actualResult, expectedResult);
    });

    test(
        'Should return True when minLength is 10 and password has 15 character',
        () {
      // arrange
      String password = "sjdidmgldismaudt";
      int minLength = 10;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinLength(password, minLength);

      // assert
      expect(actualResult, expectedResult);
    });
  });
  group("Tests for hasMinUppercase() component", () {
    late Validator validator;

    setUp(() {
      validator = new Validator();
    });

    test(
        'Should return True when uppercaseCount is 2 and password has 2 uppercase character',
        () {
      // arrange
      String password = "djgmkSsoldqA";
      int uppercaseCount = 2;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinUppercase(password, uppercaseCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test(
        'Should return False when uppercaseCount is 5 and password has 3 uppercase character',
        () {
      // arrange
      String password = "dTjgmkSsoldqA";
      int uppercaseCount = 5;
      bool expectedResult = false;

      // act
      bool actualResult = validator.hasMinUppercase(password, uppercaseCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test(
        'Should return True when uppercaseCount is 3 and password has 5 uppercase character',
        () {
      // arrange
      String password = "dTjgmkSsoldqAsdsdRsdsU";
      int uppercaseCount = 5;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinUppercase(password, uppercaseCount);

      // assert
      expect(actualResult, expectedResult);
    });
  });
  group("Test for hasMinNumericChar() component", (){

    late Validator validator;
    setUp(() {
      validator = new Validator();
    });

    test("Should return True when numericCount is 2 and password has 2 numeric character", (){
      // arrange
      String password = "sdsdlkl2l;l;2";
      int numericCount = 2;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinNumericChar(password, numericCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test("Should return False when numericCount is 5 and password has 3 numeric character", (){
      // arrange
      String password = "4sdsdlkl2l;l;2";
      int numericCount = 5;
      bool expectedResult = false;

      // act
      bool actualResult = validator.hasMinNumericChar(password, numericCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test("Should return True when numericCount is 3 and password has 5 numeric character", (){
      // arrange
      String password = "4sdsdlkl2l;l;2iiiis1kkksd9";
      int numericCount = 3;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinNumericChar(password, numericCount);

      // assert
      expect(actualResult, expectedResult);
    });
  });
  group("Test for hasMinSpecialChar() component", (){

    late Validator validator;
    setUp(() {
      validator = new Validator();
    });

    test("Should return True when specialCount is 2 and password has 2 special character", (){
      // arrange
      String password = "aaaaaa@aaaa@";
      int specialCount = 2;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinSpecialChar(password, specialCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test("Should return False when specialCount is 5 and password has 3 special character", (){
      // arrange
      String password = "#aaaaaa@aaaa@";
      int specialCount = 5;
      bool expectedResult = false;

      // act
      bool actualResult = validator.hasMinSpecialChar(password, specialCount);

      // assert
      expect(actualResult, expectedResult);
    });

    test("Should return True when specialCount is 3 and password has 5 special character", (){
      // arrange
      String password = "#aaaaaa@aaaa-bbbb/ssss!";
      int specialCount = 3;
      bool expectedResult = true;

      // act
      bool actualResult = validator.hasMinSpecialChar(password, specialCount);

      // assert
      expect(actualResult, expectedResult);
    });
  });
}

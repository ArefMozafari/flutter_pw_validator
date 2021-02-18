# Flutter Pw Validator

![License](https://img.shields.io/github/license/ArefMozafari/flutter_pw_validator?style=flat-square) ![Pub Version](https://img.shields.io/pub/v/flutter_pw_validator?style=flat-square) ![GitHub stars](https://img.shields.io/github/stars/ArefMozafari/flutter_pw_validator?style=flat-square)


<img src="https://user-images.githubusercontent.com/29792606/108348045-89a33480-71f6-11eb-99a9-bf56a09f0e26.gif" width="275"> <img src="https://user-images.githubusercontent.com/29792606/108348177-afc8d480-71f6-11eb-991c-34fad5bcf621.gif" width="275"> <img src="https://user-images.githubusercontent.com/29792606/108348154-a9d2f380-71f6-11eb-9c80-20400eba992e.gif" width="275">

#

Flutter Pw Validator package helps you to validate sign in user-entered password with your rules.


## How to use
### 1- Depend on it
#### Add it to your package's pubspec.yaml file:
```yml
dependencies:
  flutter_pw_validator: ^1.0.0
```
### 2- Install it
#### Install packages from the command line:
```sh
flutter pub get
```

### 3- Usage
#### First You have to import the file:
```dart
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
```
#### And then just put it right under your password TextField and pass the controller to that:
```dart
new TextField(
    controller: _passwordController
),
new FlutterPwValidator(
    controller: _passwordController,
    minLength: 6,
    uppercaseCharCount: 2,
    numericCharCount: 3,
    specialCharCount: 1,
    width: 400,
    height: 150,
    onSuccess: yourCallbackFunction
)
```
### Properties
|Property		|Description	|Default Value |Required |
|:---------------|:---------------|:-------|:------|
|controller|Takes your password TextField controller|null|Yes|
|minLength|Takes total minimum length of password|null|Yes|
|uppercaseCharCount|Takes minimum uppercase character count that has to include in the password|0|No|
|numericCharCount|Takes minimum numeric character count that has to include in the password|0|No|
|specialCharCount|Takes minimum special character count that has to include in the password|0|No|
|width|Takes the widget width|null|Yes|
|height|Takes the widget height|null|Yes|
|onSuccess|Takes a void callback function that runs when the password is matched with condition(s)|null|Yes|
|defaultColor|Takes default state color of the widget|Color(0xFFd3d3d3)|No|
|successColor|Takes success state color of the widget|Color(0xFF2ee292)|No|
|failureColor|Takes failure state color of the widget|Color(0xFFf9433e)|No|


</br>

## Example Project
### You can use this [example project](https://github.com/XeniacDev/flutter_pw_validator/tree/master/example) to see how it works.

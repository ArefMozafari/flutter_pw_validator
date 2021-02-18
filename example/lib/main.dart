import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text("Flutter Pw Validator"),
            ),
            body: new AppHome()));
  }
}

class AppHome extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Stack(
        children: [ Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.5),
          child: Column(
            children: [
              new Flexible(flex: 5, child: new FlutterLogo(size: 200)),
              Flexible(
                flex: 7,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:2.0),
                      child: new TextField(
                          controller: controller,
                          decoration: new InputDecoration(
                              hintText: "Password",
                              border: new OutlineInputBorder(
                                  borderSide: BorderSide()))),
                    ),
                    new SizedBox(
                      height: 5,
                    ),
                    new FlutterPwValidator(
                      controller: controller,
                      minLength: 6,
                      uppercaseCharCount: 2,
                      numericCharCount: 2,
                      specialCharCount: 1,
                      width: 400,
                      height: 150,
                      onSuccess: () {
                        print("Matched");
                        Scaffold.of(context).showSnackBar(new SnackBar(
                            content: new Text("Password is matched")));
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        ]
    );
  }
}

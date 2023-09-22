import 'package:flutter/material.dart';
import 'package:kees/screen/homepage.dart';

// import 'input_page.dart';

// ignore: prefer_const_constructors
void main() => runApp(mainPage());

// ignore: camel_case_types
class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Color(0xFF110F1A),
              ),
          scaffoldBackgroundColor: Color.fromARGB(255, 246, 229, 229),
          textTheme:
              const TextTheme(bodyLarge: TextStyle(color: Colors.white))),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

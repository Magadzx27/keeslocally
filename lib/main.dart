import 'package:flutter/material.dart';
import 'package:kees/screen/homepage.dart';
import 'package:kees/screen/mainPage.dart';
import 'package:provider/provider.dart';

// import 'input_page.dart';

// ignore: prefer_const_constructors
void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AppState(), // Initialize the app state
        child: mainPage(),
      ),
    );

// ignore: camel_case_types
class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Color.fromARGB(255, 1, 78, 70),
              ),
          scaffoldBackgroundColor: Colors.white,
          textTheme:
              const TextTheme(bodyLarge: TextStyle(color: Colors.white))),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

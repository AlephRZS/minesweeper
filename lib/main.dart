import 'package:flutter/material.dart';

import 'screens/main_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context = context;
    return MaterialApp(
      title: 'Minesweeper',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
          textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.blue),
      )),
      home: const MainMenu(),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import 'board_space.dart';

void main() {
  runApp(const MyApp());
}

bool minesSet = false;
int mineCounter = 0;
List<BoardSpace> board = List.generate(100, (index) => BoardSpace());

void setMinesRandomly() {
  if (!minesSet) {
    while (mineCounter < 80) {
      Random rand = Random();
      int num = rand.nextInt(100);
      if (!board[num].isMined && board[num].enabled) {
        board[num].isMined = true;
        mineCounter++;
      }
    }
    minesSet = true;
  }
}

void restart() {
  minesSet = false;
  mineCounter = 0;
  board = List.generate(100, (index) => BoardSpace());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context = context;
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: 'Minesweeper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textsHidden = false;
  List<bool> buttonState = List<bool>.generate(100, (i) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () {
              setState(() {
                restart();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Game Settings',
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "${mineCounter} Mines left",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                return board[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}

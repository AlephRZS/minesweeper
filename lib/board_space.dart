import 'dart:math';

import 'package:flutter/material.dart';

class MineField extends StatefulWidget {
  const MineField(
      {required this.columns,
      required this.rows,
      required this.mines,
      Key? key})
      : super(key: key);
  final int columns;
  final int rows;
  final int mines;

  @override
  _MineFieldState createState() => _MineFieldState();
}

class _MineFieldState extends State<MineField> {
  int mines = 0;
  int flagsSet = 0;
  bool minesSet = false;
  List<BoardSpace>? board;
  String message = "";

  bool flagAvailable() {
    return flagsSet < widget.mines;
  }

  void loseGame() {
    setState(() {
      message = "You lost";
    });
  }

  void setMines(int index) {
    Random rand = Random();
    while (mines < widget.mines) {
      int mineIndex = rand.nextInt(widget.rows * widget.columns);
      if (mineIndex != index) {
        board![index] = BoardSpace(
          parentState: this,
          index: index,
          hasMine: true,
        );
        mines++;
      }
    }
    minesSet = true;
  }

  @override
  void initState() {
    super.initState();
    message = "${widget.mines} Mines Remaining";
    board = List<BoardSpace>.generate(
      widget.columns * widget.rows,
      (index) => BoardSpace(
        parentState: this,
        index: index,
        hasMine: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          message,
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
              return (board != null)
                  ? board![index]
                  : BoardSpace(
                      parentState: this,
                      index: 0,
                      hasMine: true,
                    );
            },
          ),
        ),
      ],
    );
  }
}

class BoardSpace extends StatefulWidget {
  const BoardSpace({
    required this.parentState,
    required this.index,
    required this.hasMine,
    Key? key,
  }) : super(key: key);
  final _MineFieldState parentState;
  final int index;
  final bool hasMine;

  @override
  _BoardSpaceState createState() => _BoardSpaceState();
}

class _BoardSpaceState extends State<BoardSpace> {
  bool clickable = true;
  bool revealed = false;
  bool hasFlag = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: revealed ? Colors.blueGrey : Colors.blueAccent,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: clickable ? _buttonFlag : null,
        onTap: clickable ? _buttonClick : null,
        child: Center(
          child: hasFlag ? const Icon(Icons.flag_sharp) : null,
        ),
      ),
    );
  }

  void _buttonFlag() {
    if (!hasFlag && widget.parentState.flagAvailable()) {
      widget.parentState.flagsSet++;
    } else if (hasFlag) {
      widget.parentState.flagsSet--;
    } else {
      return;
    }
    setState(() {
      hasFlag = !hasFlag;
    });
  }

  void _buttonClick() {
    if (!hasFlag) {
      if (!widget.parentState.minesSet) {
        widget.parentState.setMines(widget.index);
      }
      if (widget.hasMine) {
        widget.parentState.loseGame();
      }
      setState(() {
        clickable = false;
        revealed = true;
      });
    }
  }
}

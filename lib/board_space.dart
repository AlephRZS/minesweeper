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
  bool lostGame = false;

  bool flagAvailable() {
    return flagsSet < widget.mines;
  }

  void loseGame() {
    setState(() {
      message = "You lost";
      lostGame = true;
    });
  }

  int countBombs(int index) {
    Random rand = Random();
    return rand.nextInt(8);
  }

  void setMines(int index) {
    Random rand = Random();
    while (mines < widget.mines) {
      int mineIndex = rand.nextInt(widget.rows * widget.columns);
      if (mineIndex != index) {
        board![mineIndex] = BoardSpace(
          parentState: this,
          index: index,
          hasMine: true,
        );
        mines++;
      }
    }
    setState(() {
      message = "$mines mines remaining";
      minesSet = true;
    });
  }

  @override
  void initState() {
    super.initState();
    message = "Start game with ${widget.mines} mines";
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
                  ? Stack(
                      children: [
                        board![index],
                        Center(
                          child: board![index].hasMine && lostGame
                              ? const Icon(Icons.offline_bolt)
                              : null,
                        ),
                      ],
                    )
                  : BoardSpace(
                      parentState: this,
                      index: 0,
                      hasMine: false,
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
  int bombsNearby = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: revealed ? Colors.blueGrey : Colors.blueAccent,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: clickable ? _buttonFlag : null,
        onTap: clickable ? _buttonClick : null,
        child: Stack(children: [
          Center(
            child: hasFlag ? const Icon(Icons.flag_sharp) : null,
          ),
          Center(
              child: bombsNearby != 0 && revealed && !widget.hasMine
                  ? Text("$bombsNearby")
                  : null),
        ]),
      ),
    );
  }

  void _buttonFlag() {
    if (widget.parentState.lostGame) return;
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
    _MineFieldState boardState = widget.parentState;
    boardState.setState(() {
      boardState.message =
          "${boardState.mines - boardState.flagsSet} mines remaining";
    });
  }

  void _buttonClick() {
    if (widget.parentState.lostGame) return;
    if (!hasFlag) {
      if (!widget.parentState.minesSet) {
        widget.parentState.setMines(widget.index);
      }
      if (widget.hasMine) {
        widget.parentState.loseGame();
      }

      bombsNearby = widget.parentState.countBombs(widget.index);

      setState(() {
        clickable = false;
        revealed = true;
      });
    }
  }
}

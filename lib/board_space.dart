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
  List<BoardBlock>? gameBoard;
  String message = "";
  bool lostGame = false;
  int openedSpaces = 0;
  final numbers = List.unmodifiable([
    null,
    const Text(
      '1',
      style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w700),
    ),
    const Text(
      '2',
      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
    ),
    const Text(
      '3',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
    ),
    const Text(
      '4',
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
    ),
    const Text(
      '5',
      style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w700),
    ),
    const Text(
      '6',
      style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.w700),
    ),
    const Text(
      '7',
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
    ),
    const Text(
      '8',
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
    ),
  ]);

  bool flagAvailable() {
    return flagsSet < widget.mines;
  }

  void loseGame() {
    setState(() {
      message = "You lost";
      lostGame = true;
    });
  }

  void checkWinGame() {
    openedSpaces++;
    if (openedSpaces == widget.rows * widget.columns - widget.mines) {
      setState(() {
        message = "You Won!!!";
      });
    }
  }

  int countBombs(int index) {
    Random rand = Random();
    List<int> countSpaces = getNeighbourMines(index);
    int counter = 0;
    for (int num in countSpaces) {
      if (board![num].hasMine) {
        counter++;
      }
    }
    return counter;
  }

  /*
  0 1 2
  3 X 4
  5 6 7
  */
  List<int> getNeighbourMines(int index) {
    List<int> neighbourMines = [];
    int row = index ~/ widget.columns;
    int column = index - widget.columns * row;

    if (row > 0) neighbourMines.add(index - widget.columns); //1
    if (row < widget.rows - 1) neighbourMines.add(index + widget.columns); //6
    if (column > 0) neighbourMines.add(index - 1); //3
    if (column < widget.columns - 1) neighbourMines.add(index + 1); //4
    if (row > 0 && column > 0) {
      neighbourMines.add(index - widget.columns - 1);
    } //0
    if (row < widget.rows - 1 && column < widget.columns - 1) {
      neighbourMines.add(index + widget.columns + 1);
    } //7
    if (row > 0 && column < widget.columns - 1) {
      neighbourMines.add(index - widget.columns + 1);
    } //2
    if (column > 0 && row < widget.rows - 1) {
      neighbourMines.add(index + widget.columns - 1);
    } //5

    return neighbourMines;
  }

  void setMines(int index) {
    Random rand = Random();
    List<int> blockedRegion = getNeighbourMines(index);
    blockedRegion.add(index);
    while (mines < widget.mines) {
      int mineIndex = rand.nextInt(widget.rows * widget.columns);
      if (!blockedRegion.contains(mineIndex)) {
        board![mineIndex] = BoardSpace(
          parentState: this,
          index: index,
          hasMine: true,
        );
        mines++;
        blockedRegion.add(mineIndex);
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

  toggleFlag(int index) {}

  clickSpace(int index) {}

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
            itemCount: widget.columns * widget.rows,
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

class BoardBlock extends StatelessWidget {
  const BoardBlock({
    required this.hasFlag,
    required this.index,
    required this.parentState,
    Key? key,
  }) : super(key: key);
  final bool hasFlag;
  final int index;
  final _MineFieldState parentState;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: parentState.toggleFlag(index),
        onTap: parentState.clickSpace(index),
        child: hasFlag ? const Icon(Icons.flag) : null,
      ),
    );
  }
}

class RevealedBlock extends BoardBlock {
  const RevealedBlock({
    required this.hasFlag,
    required this.index,
    required this.parentState,
    required this.minesNearby,
    Key? key,
  }) : super(
            hasFlag: hasFlag, index: index, parentState: parentState, key: key);
  final bool hasFlag;
  final int index;
  final _MineFieldState parentState;
  final int minesNearby;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        splashColor: Colors.grey,
        child: parentState.numbers[minesNearby],
      ),
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
          Center(child: widget.parentState.numbers[bombsNearby]),
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

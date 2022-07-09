import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minesweeper/screens/main_menu.dart';

import 'screens/game_play.dart';

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
  late List<BoardBlock> gameBoard;
  bool gameEnded = false;
  bool gameWon = false;
  bool minesSet = false;

  int flagsSet = 0;
  int openedSpaces = 0;

  bool controllsInverted = false;

  Timer? _timer;
  int seconds = 0;

  void restartGame() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePlay()));
  }

  final numbers = List.unmodifiable([
    null,
    const Text(
      '1',
      style: TextStyle(
          color: Color.fromARGB(255, 47, 93, 155),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '2',
      style: TextStyle(
          color: Color.fromARGB(255, 6, 114, 10),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '3',
      style: TextStyle(
          color: Color.fromARGB(255, 175, 16, 4),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '4',
      style: TextStyle(
          color: Color.fromARGB(255, 3, 49, 87),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '5',
      style: TextStyle(
          color: Color.fromARGB(255, 124, 40, 14),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '6',
      style: TextStyle(
          color: Color.fromARGB(255, 0, 111, 126),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
    const Text(
      '7',
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
    ),
    const Text(
      '8',
      style: TextStyle(
          color: Color.fromARGB(255, 66, 66, 66),
          fontWeight: FontWeight.w700,
          fontSize: 20),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    gameBoard = List<BoardBlock>.generate(
      widget.columns * widget.rows,
      (index) => BoardBlock(
        index: index,
        hasFlag: false,
        hasMine: false,
        parentState: this,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (gameEnded || seconds > 999) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            seconds++;
          });
        }
      },
    );
  }

  invertControlls() {
    setState(() {
      controllsInverted = !controllsInverted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Container(
              width: 75,
              child: Card(
                margin: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                color: const Color.fromARGB(255, 196, 196, 196),
                child: Center(
                  child: Text(
                    '${(widget.mines - flagsSet < 10 ? 0 : '')}${widget.mines - flagsSet}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => invertControlls(),
              icon: controllsInverted
                  ? const ImageIcon(
                      AssetImage("assets/flag.png"),
                      size: 32,
                    )
                  : const ImageIcon(
                      AssetImage("assets/mine.png"),
                      size: 32,
                    ),
              color: const Color.fromARGB(255, 141, 184, 250),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.restart_alt_sharp),
                onPressed: restartGame,
                color: const Color.fromARGB(255, 141, 184, 250),
              ),
            ),
            SizedBox(
              width: 75,
              child: Card(
                margin:
                    const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                color: const Color.fromARGB(255, 196, 196, 196),
                child: Center(
                  child: Text(
                    '${seconds < 10 ? '00' : (seconds < 100 ? 0 : '')}$seconds',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: gameWon ? Colors.greenAccent : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.columns,
            ),
            itemCount: widget.columns * widget.rows,
            itemBuilder: (context, index) {
              return gameBoard[index];
            },
          ),
        ),
      ],
    );
  }

  bool flagAvailable() {
    return flagsSet < widget.mines;
  }

  void loseGame(int index) {
    revealMines();
    gameBoard[index] = MineBlock(redColor: true, parentState: this);
    setState(() {
      gameEnded = true;
    });
  }

  void checkWinGame() {
    openedSpaces++;
    if (openedSpaces == widget.rows * widget.columns - widget.mines) {
      setState(() {
        gameEnded = true;
        gameWon = true;
      });
    }
  }

  void revealMines() {
    for (var i = 0; i < gameBoard.length; i++) {
      if (gameBoard[i].hasMine) {
        gameBoard[i] = MineBlock(redColor: false, parentState: this);
      }
    }
  }

  int countBombs(int index) {
    List<int> countSpaces = getNeighbourMines(index);
    int counter = 0;
    for (int num in countSpaces) {
      if (gameBoard[num].hasMine) {
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
    int mines = 0;
    while (mines < widget.mines) {
      int mineIndex = rand.nextInt(widget.rows * widget.columns);
      if (!blockedRegion.contains(mineIndex)) {
        bool flagInBlock = gameBoard[mineIndex].hasFlag;
        gameBoard[mineIndex] = BoardBlock(
          index: mineIndex,
          hasFlag: flagInBlock,
          hasMine: true,
          parentState: this,
        );
        mines++;
        blockedRegion.add(mineIndex);
      }
    }
    setState(() {
      minesSet = true;
    });
    startTimer();
  }

  toggleFlag(int index) {
    if (gameEnded) return;
    bool flagInBlock = gameBoard[index].hasFlag;
    if (!flagInBlock && flagAvailable()) {
      flagsSet++;
    } else if (flagInBlock) {
      flagsSet--;
    } else {
      return;
    }
    bool mineInBlock = gameBoard[index].hasMine;
    gameBoard[index] = BoardBlock(
        index: index,
        hasFlag: !flagInBlock,
        hasMine: mineInBlock,
        parentState: this);

    setState(() {});
  }

  clickSpace(int index) {
    if (gameEnded) return;
    if (!gameBoard[index].hasFlag) {
      if (!minesSet) {
        setMines(index);
      } else if (gameBoard[index].hasMine) {
        loseGame(index);
        return;
      }
      int minesNearby = countBombs(index);
      setState(() {
        gameBoard[index] = RevealedBlock(
            index: index, parentState: this, minesNearby: minesNearby);
      });
      if (minesNearby == 0) {
        for (int num in getNeighbourMines(index)) {
          if (gameBoard[num] is! RevealedBlock) {
            clickSpace(num);
          }
        }
      }
      checkWinGame();
    }
  }

  revealedClick(int index, int minesNearby) {
    List<int> neighbours = getNeighbourMines(index);
    int counter = 0;
    for (int num in neighbours) {
      if (gameBoard[num].hasFlag) counter++;
    }
    if (minesNearby == counter) {
      for (int num in neighbours) {
        if (gameBoard[num] is! RevealedBlock) {
          clickSpace(num);
        }
      }
    }
  }
}

class BoardBlock extends StatelessWidget {
  const BoardBlock({
    required this.index,
    required this.hasFlag,
    required this.hasMine,
    required this.parentState,
    Key? key,
  }) : super(key: key);
  final int index;
  final bool hasFlag;
  final bool hasMine;
  final _MineFieldState parentState;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      margin: const EdgeInsets.all(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(width: 0.5, color: Colors.black),
      ),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: () => parentState.controllsInverted
            ? parentState.clickSpace(index)
            : parentState.toggleFlag(index),
        onTap: () => parentState.controllsInverted
            ? parentState.toggleFlag(index)
            : parentState.clickSpace(index),
        child: hasFlag
            ? const Center(
                child: ImageIcon(
                AssetImage("assets/flag.png"),
                size: 32,
                color: Colors.black,
              ))
            : null,
      ),
    );
  }
}

class MineBlock extends BoardBlock {
  const MineBlock(
      {required this.redColor, required _MineFieldState parentState, Key? key})
      : super(
            index: 0,
            hasFlag: false,
            hasMine: true,
            parentState: parentState,
            key: key);
  final bool redColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          redColor ? const Color.fromARGB(255, 172, 42, 33) : Colors.blueAccent,
      margin: const EdgeInsets.all(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(width: 0.5, color: Colors.black),
      ),
      child: const Center(
        child: ImageIcon(
          AssetImage("assets/mine.png"),
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}

class RevealedBlock extends BoardBlock {
  const RevealedBlock({
    required int index,
    required _MineFieldState parentState,
    required this.minesNearby,
    Key? key,
  }) : super(
            index: index,
            hasFlag: false,
            hasMine: false,
            parentState: parentState,
            key: key);
  final int minesNearby;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      margin: const EdgeInsets.all(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(width: 0.5, color: Colors.black),
      ),
      child: InkWell(
        splashColor: Colors.grey,
        child: Center(child: parentState.numbers[minesNearby]),
        onTap: () => parentState.revealedClick(index, minesNearby),
      ),
    );
  }
}

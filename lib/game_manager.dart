import 'package:minesweeper/board_space.dart';

enum Difficulty {
  easy,
  normal,
  hard,
}

class GameManager {
  static final GameManager _gameManager = GameManager._internal();
  Difficulty diff = Difficulty.easy;

  factory GameManager() {
    return _gameManager;
  }

  GameManager._internal();

  set diffifculty(Difficulty diff) {
    this.diff = diff;
  }

  MineField createField() {
    MineField minef;
    switch (diff) {
      case Difficulty.normal:
        minef = const MineField(columns: 12, rows: 20, mines: 40);
        break;
      case Difficulty.hard:
        minef = const MineField(columns: 16, rows: 28, mines: 99);
        break;
      default:
        minef = const MineField(columns: 7, rows: 12, mines: 10);
    }
    return minef;
  }
}

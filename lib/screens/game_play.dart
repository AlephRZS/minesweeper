import 'package:flutter/material.dart';
import 'package:minesweeper/game_manager.dart';

import '../board_space.dart';
import 'main_menu.dart';

late MineField _mineField;

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _mineField = GameManager().createField();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        actions: <Widget>[
          IconButton(
            onPressed: () => {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainMenu()))
            },
            color: const Color.fromARGB(255, 141, 184, 250),
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _mineField,
    );
  }
}

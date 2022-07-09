import 'package:flutter/material.dart';
import 'package:minesweeper/game_manager.dart';
import 'package:minesweeper/screens/game_play.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  _startGame(Difficulty diff, BuildContext context) {
    GameManager man = GameManager();
    man.diffifculty = diff;

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePlay()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        actions: <Widget>[
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Image.asset('assets/menubanner.png')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => {_startGame(Difficulty.easy, context)},
                child: const Text('Easy'),
              ),
            ),
            ElevatedButton(
              onPressed: () => {_startGame(Difficulty.normal, context)},
              child: const Text('Normal'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => {_startGame(Difficulty.hard, context)},
                child: const Text('Hard'),
              ),
            ),
            ElevatedButton(
              onPressed: () => {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Endless Mode is not ready yet.")))
              },
              child: const Text('Endless Mode'),
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

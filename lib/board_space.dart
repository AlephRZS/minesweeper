import 'package:flutter/material.dart';
import 'main.dart';

class BoardSpace extends StatefulWidget {
  BoardSpace({
    Key? key,
  }) : super(key: key);

  bool isMined = false;
  bool enabled = true;
  bool flagged = false;

  @override
  _BoardSpaceState createState() => _BoardSpaceState();
}

class _BoardSpaceState extends State<BoardSpace> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.enabled ? Colors.blueAccent : Colors.blueGrey,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: _buttonFlag,
        onTap: _buttonClick,
        child: Stack(
          children: [
            Center(
              child: widget.flagged ? const Icon(Icons.flag_sharp) : null,
            ),
            Center(
                child: widget.isMined && !widget.enabled
                    ? const Icon(Icons.bolt_sharp)
                    : null),
          ],
        ),
      ),
    );
  }

  _buttonFlag() {
    if (widget.enabled) {
      setState(() {
        widget.flagged = !widget.flagged;
      });
    }
  }

  _buttonClick() {
    if (!widget.flagged) {
      setState(() {
        widget.enabled = false;
        setMinesRandomly();
      });
    }
  }
}

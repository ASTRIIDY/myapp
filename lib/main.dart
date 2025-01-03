import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha',
      home: ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha o Modo de Jogo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SymbolSelectionScreen(isSinglePlayer: true)),
                );
              },
              child: Text('Jogar contra a Máquina'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SymbolSelectionScreen(isSinglePlayer: false)),
                );
              },
              child: Text('Jogar contra um Amigo'),
            ),
          ],
        ),
      ),
    );
  }
}

class SymbolSelectionScreen extends StatelessWidget {
  final bool isSinglePlayer;

  SymbolSelectionScreen({required this.isSinglePlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha seu Símbolo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicTacToe(isSinglePlayer: isSinglePlayer, playerSymbol: 'X')),
                );
              },
              child: Text('X'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicTacToe(isSinglePlayer: isSinglePlayer, playerSymbol: 'O')),
                );
              },
              child: Text('O'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToe extends StatefulWidget {
  final bool isSinglePlayer;
  final String playerSymbol;

  TicTacToe({required this.isSinglePlayer, required this.playerSymbol});

  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  late List<String> _board;
  late String _lastMove;
  late String _winner;
  late String _playerSymbol;
  late String _computerSymbol;

  @override
  void initState() {
    super.initState();
    _board = List<String>.filled(9, '');
    _lastMove = 'X';
    _winner = '';
    _playerSymbol = widget.playerSymbol;
    _computerSymbol = _playerSymbol == 'X' ? 'O' : 'X';

    if (widget.isSinglePlayer && _playerSymbol == 'O') {
      _makeComputerMove(); // Computador começa o jogo
    }
  }

  void _resetGame() {
    setState(() {
      _board = List<String>.filled(9, '');
      _lastMove = 'X';
      _winner = '';
    });

    if (widget.isSinglePlayer && _playerSymbol == 'O') {
      _makeComputerMove(); // Computador começa o jogo novamente
    }
  }

  void _makeMove(int index) {
    if (_board[index] == '' && _winner == '') {
      setState(() {
        _board[index] = _lastMove;
        _lastMove = _lastMove == 'X' ? 'O' : 'X';
        _winner = _checkWinner();
      });

      if (_winner.isNotEmpty) {
        _showWinnerDialog(_winner);
      } else if (!_board.contains('')) {
        _showWinnerDialog('Velha');
      } else if (widget.isSinglePlayer && _lastMove == _computerSymbol) {
        _makeComputerMove();
      }
    }
  }

  void _makeComputerMove() {
    Random random = Random();
    int index;
    do {
      index = random.nextInt(9);
    } while (_board[index] != '');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_winner == '' && _board.contains('')) {
        setState(() {
          _board[index] = _computerSymbol;
          _lastMove = _playerSymbol;
          _winner = _checkWinner();
        });

        if (_winner.isNotEmpty) {
          _showWinnerDialog(_winner);
        } else if (!_board.contains('')) {
          _showWinnerDialog('Velha');
        }
      }
    });
  }

  String _checkWinner() {
    const List<List<int>> _winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in _winningCombinations) {
      if (_board[combo[0]] != '' &&
          _board[combo[0]] == _board[combo[1]] &&
          _board[combo[1]] == _board[combo[2]]) {
        return _board[combo[0]];
      }
    }

    if (!_board.contains('')) {
      return 'Velha';
    }

    return '';
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(winner == 'Velha' ? 'Deu Velha!' : 'Temos um Vencedor!'),
          content: Text(
              winner == 'Velha' ? 'O jogo terminou em empate!' : 'Jogador $winner venceu!'),
          actions: <Widget>[
            TextButton(
              child: Text('Reiniciar'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da Velha'),
      ),
      body: Column(
        children: <Widget>[
          _buildBoard(),
          _buildResult(),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _makeMove(index),
            child: Container(
              margin: EdgeInsets.all(4.0),
              color: Colors.blue[100],
              child: Center(
                child: Text(
                  _board[index],
                  style: TextStyle(fontSize: 32.0),
                ),
              ),
            ),
          );
        },
        itemCount: 9,
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        _winner == 'Velha'
            ? 'Deu Velha!'
            : _winner.isNotEmpty
                ? 'Jogador $_winner venceu!'
                : 'Vez do jogador $_lastMove',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _winner.isNotEmpty || !_board.contains('')
          ? _resetGame
          : null,
      child: Text('Reiniciar Jogo'),
    );
  }
}



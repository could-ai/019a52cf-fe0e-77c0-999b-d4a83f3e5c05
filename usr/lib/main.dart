import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candy Worm Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GamePage(),
    );
  }
}

enum Direction { up, down, left, right }

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int gridSize = 20;
  static const double cellSize = 30.0;
  List<Offset> snake = [];
  Offset? candy;
  Direction direction = Direction.right;
  Timer? gameTimer;
  bool isPlaying = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      score = 0;
      direction = Direction.right;
      snake = [const Offset(5, 5)];
      generateCandy();
      isPlaying = true;
      gameTimer?.cancel();
      gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        updateGame();
      });
    });
  }

  void generateCandy() {
    final random = Random();
    Offset newCandy;
    do {
      newCandy = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(newCandy));
    setState(() {
      candy = newCandy;
    });
  }

  void updateGame() {
    if (!isPlaying) return;

    setState(() {
      Offset newHead;
      switch (direction) {
        case Direction.up:
          newHead = Offset(snake.first.dx, snake.first.dy - 1);
          break;
        case Direction.down:
          newHead = Offset(snake.first.dx, snake.first.dy + 1);
          break;
        case Direction.left:
          newHead = Offset(snake.first.dx - 1, snake.first.dy);
          break;
        case Direction.right:
          newHead = Offset(snake.first.dx + 1, snake.first.dy);
          break;
      }

      // Wall collision
      if (newHead.dx < 0 ||
          newHead.dx >= gridSize ||
          newHead.dy < 0 ||
          newHead.dy >= gridSize) {
        gameOver();
        return;
      }

      // Self collision
      if (snake.contains(newHead)) {
        gameOver();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == candy) {
        score++;
        generateCandy();
      } else {
        snake.removeLast();
      }
    });
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && direction != Direction.down) {
        direction = Direction.up;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && direction != Direction.up) {
        direction = Direction.down;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && direction != Direction.right) {
        direction = Direction.left;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && direction != Direction.left) {
        direction = Direction.right;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Score: $score',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              Container(
                width: gridSize * cellSize,
                height: gridSize * cellSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[900],
                ),
                child: Stack(
                  children: [
                    // Draw snake
                    ...snake.map((segment) => Positioned(
                          left: segment.dx * cellSize,
                          top: segment.dy * cellSize,
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )),
                    // Draw candy
                    if (candy != null)
                      Positioned(
                        left: candy!.dx * cellSize,
                        top: candy!.dy * cellSize,
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    // Game Over / Start Screen
                    if (!isPlaying)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                score == 0 ? 'Candy Worm Arena' : 'Game Over',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (score > 0)
                                Text(
                                  'Your Score: $score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: startGame,
                                child: Text(score == 0 ? 'Start Game' : 'Restart'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

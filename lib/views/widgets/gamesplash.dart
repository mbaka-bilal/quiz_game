import 'package:flutter/material.dart';
import 'package:quiz_game/views/widgets/audio.dart';
import 'package:quiz_game/views/widgets/doublecurvedcontainer.dart';

class GameSplash extends StatefulWidget {
  GameSplash({
    Key? key,
    required this.level,
    required this.onComplete,
  }) : super(key: key);

  final String level;
  final VoidCallback onComplete;

  @override
  _GameSplashState createState() => _GameSplashState();
}

class _GameSplashState extends State<GameSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationAppear;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onComplete != null) {
            widget.onComplete();
          }
        }
      });

    _animationAppear = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.1,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Play the intro
    Audio.playAsset(AudioType.game_start);

    // Launch the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animationAppear,
      child: Material(
        color: Colors.transparent,
        child: DoubleCurvedContainer(
          width: screenSize.width,
          height: 150.0,
          outerColor: Colors.blue.shade700,
          innerColor: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: Text(
                  'Stage:  ${widget.level}',
                  style: const TextStyle(fontSize: 24.0, color: Colors.white),
                )),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return Positioned(
          left: 0.0,
          top: 150.0 + 100.0 * _animationAppear.value,
          child: child!,
        );
      },
    );
  }
}

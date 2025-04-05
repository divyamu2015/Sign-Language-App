import 'package:flutter/material.dart';

class DancingDoll extends StatefulWidget {
  const DancingDoll({super.key});

  @override
  _DancingDollState createState() => _DancingDollState();
}

class _DancingDollState extends State<DancingDoll>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * 3.14159).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: Center(
              child: Text(
                "Doll",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

class ViewRewards extends StatefulWidget {
  const ViewRewards({super.key, required this.count, required this.totalScore});
  final int count;
  final int totalScore;

  @override
  State<ViewRewards> createState() => _ViewRewardsState();
}

class _ViewRewardsState extends State<ViewRewards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  int? count;
  int? totalScore;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    count = widget.count;
    totalScore = widget.totalScore;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 218, 243, 204),
        appBar: AppBar(
          title: Text(
            "My Score Board",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 87, 49, 94),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/pink-teddy-bear-white-background.png',
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              //  const Text("Name: Divya", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text("Coin Score: $count ", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text("Total Mark: $totalScore", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'))
            ],
          ),
        ),
      ),
    );
  }
}

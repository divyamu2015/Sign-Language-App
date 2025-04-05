import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/numbers.mp4') // Local video
          ..initialize().then((_) {
            setState(() {}); // Refresh UI when video is loaded
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber[100],
          title: const Text("Number Image"),
          content: Image.asset(
            'assets/images/numbers.jpg', // Replace with your image path
            width: 200,
            height: 300,
            fit: BoxFit.cover,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Welcome Home',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 87, 49, 94)),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                Color.fromARGB(255, 213, 148, 221),
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                Color.fromARGB(255, 213, 148, 221),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                      onPressed: _showImageDialog,
                      child: Text(
                        'Image',
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 18.0,
                          decoration: TextDecoration.underline,
                        ),
                      )),
                ),
                const SizedBox(
                  height: 5,
                ),
                _controller.value.isInitialized
                    ? SizedBox(
                        width: 500, // Set custom width
                        height: 400, // Set custom height
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Text(
                    _controller.value.isPlaying ? "Pause" : "Play",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

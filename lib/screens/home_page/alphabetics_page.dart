import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class AlphabeticsScreen extends StatefulWidget {
  const AlphabeticsScreen({super.key});

  @override
  State<AlphabeticsScreen> createState() => _AlphabeticsScreenState();
}

class _AlphabeticsScreenState extends State<AlphabeticsScreen> {
  late VideoPlayerController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/videos/alphabetics.mp4') // Local video
      ..initialize().then((_) {
        setState(() {}); // Refresh UI when video is loaded
      });

    // Play audio when the video starts playing
    // _controller.addListener(() {
    //   if (_controller.value.isPlaying && !_isAudioPlaying) {
    //     _playAudio();
    //   }
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // void _playAudio() async {
  //   await _audioPlayer.play(AssetSource('assets/audios/alphabet.mp3'));
  //   setState(() {
  //     _isAudioPlaying = true;
  //   });
  // }

  // void _pauseAudio() async {
  //   await _audioPlayer.pause();
  //   setState(() {
  //     _isAudioPlaying = false;
  //   });
  // }

  // void toggleAudio() {
  //   print(123);
  //   _isAudioPlaying ? _pauseAudio() : _playAudio();
  // }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber[100],
          title: const Text("Alphabet Image"),
          content: Image.asset(
            'assets/images/2563510_370430-PBL2S8-523.jpg', // Replace with your image path
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
            'Alphabets Video',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 87, 49, 94)),
          ),
          centerTitle: true,
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
          child: SingleChildScrollView(
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
                          height: 600, // Set custom height
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
                  // ElevatedButton(
                  //   onPressed: () {
                  //     toggleAudio();
                  //   },
                  //   child: Text(
                  //     _isAudioPlaying ? "Pause Audio" : "Play Audio",
                  //     style: GoogleFonts.poppins(fontSize: 16),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

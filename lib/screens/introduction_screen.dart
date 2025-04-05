import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../authentication_screen/login_screen/login_view/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String? userName;
  int? userId;
  String? userPass;

  List<Map<String, String>> onboardingData = [
    {
      "video": "assets/videos/istockphoto-2202262964-640_adpp_is.mp4",
      "title": "Sign Language Mastery",
      "description":
          "Learn, practice, and test your signing skills effortlessly.",
    },
    {
      "video": "assets/videos/practice.mp4",
      "title": "Sign Language Academy",
      "description": "Interactive lessons and quizzes to master sign language.",
    },
    // {
    //   "video": "assets/videos/lastvideo.mp4",
    //   "title": "Smart Sign Learning",
    //   "description":
    //       "Engage in fun quizzes and guided practice to learn sign language.",
    // },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          userName: userName,
          userId: userId,
          userPass: userPass,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: Colors.black,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 231, 173, 243),
              Color.fromARGB(255, 245, 176, 239),
              //Color.fromARGB(255, 98, 159, 238),
              Color.fromARGB(255, 213, 148, 221),
              Color.fromARGB(255, 231, 173, 243),
              Color.fromARGB(255, 245, 176, 239),
              //Color.fromARGB(255, 98, 159, 238),
              Color.fromARGB(255, 213, 148, 221),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => OnboardingContent(
                video: onboardingData[index]["video"]!,
                title: onboardingData[index]["title"]!,
                description: onboardingData[index]["description"]!,
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: _currentPage < onboardingData.length - 1
                  ? ElevatedButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 84, 69, 224)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white)),
                    onPressed: _nextPage,
                    child: Text(_currentPage == onboardingData.length - 1
                        ? "Finish"
                        : "Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatefulWidget {
  final String video, title, description;
  const OnboardingContent({
    super.key,
    required this.video,
    required this.title,
    required this.description,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 350,
          height: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.amberAccent, // Border color
              width: 4, // Border width
            ),
          ),
          child: _controller.value.isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 20),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

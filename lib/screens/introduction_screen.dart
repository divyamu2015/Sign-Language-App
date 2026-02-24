import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'package:signin_language_app/config/dev_config.dart';
import '../authentication_screen/login_screen/login_view/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "video": "assets/videos/istockphoto-2202262964-640_adpp_is.mp4",
      "title": "Welcome to\nSign Academy",
      "subtitle": "THE FUTURE OF LEARNING",
      "description": "Master American Sign Language through interactive lessons and AI-powered practice.",
    },
    {
      "video": "assets/videos/practice.mp4",
      "title": "Practice with\nConfidence",
      "subtitle": "REAL-TIME FEEDBACK",
      "description": "Our smart camera system helps you perfect every gesture with instant visual feedback.",
    },
    {
      "video": "assets/videos/alphabetics.mp4",
      "title": "Learn Anywhere,\nAnytime",
      "subtitle": "BITE-SIZED LESSONS",
      "description": "Quick daily lessons designed to fit into your busy schedule. Start your journey today!",
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Widget nextScreen;
    if (DevConfig.useDemoMode) {
      nextScreen = const HomeScreen(
          userId: DevConfig.demoUserId, userName: DevConfig.demoUserName);
    } else {
      nextScreen = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          // Background Decoration
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/back2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => OnboardingContent(
              video: onboardingData[index]["video"]!,
              title: onboardingData[index]["title"]!,
              subtitle: onboardingData[index]["subtitle"]!,
              description: onboardingData[index]["description"]!,
              index: index,
            ),
          ),
          
          // Header Actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress segments
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 4,
                        width: _currentPage == index ? 30 : 12,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? const Color(0xFF36E27B) 
                              : const Color(0xFF36E27B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  // Skip Button
                  if (_currentPage < onboardingData.length - 1)
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'SKIP',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == onboardingData.length - 1 ? 'GET STARTED' : 'CONTINUE',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatefulWidget {
  final String video, title, subtitle, description;
  final int index;

  const OnboardingContent({
    super.key,
    required this.video,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.index,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.asset(widget.video)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(true);
          _controller.setVolume(0);
        }
      }).catchError((e) {
        if (mounted) setState(() => _isError = true);
      });
  }

  @override
  void didUpdateWidget(covariant OnboardingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video != widget.video) {
      _controller.dispose();
      _initVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Container
          FadeInDown(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                   if (_controller.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  else if (_isError)
                    const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40))
                  else
                    const Center(child: CircularProgressIndicator(color: Color(0xFF36E27B))),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInRight(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF36E27B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF36E27B),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInLeft(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Text(
                   widget.title,
                  style: GoogleFonts.lexend(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: Text(
                   widget.description,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        ],
      ),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import '../config/app_config.dart';
import '../authentication_screen/login_screen/login_view/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for splash animation/time
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    final int? userId = prefs.getInt('user_id');
    final String? userName = prefs.getString('user_name');

    Widget nextScreen;

    if (AppConfig.useDemoMode) {
      nextScreen = const HomeScreen(
        userId: AppConfig.demoUserId,
        userName: AppConfig.demoUserName,
      );
    } else if (token != null && userId != null) {
      // User is already logged in
      nextScreen = HomeScreen(
        userId: userId,
        userName: userName ?? 'User',
      );
    } else {
      // Not logged in
      nextScreen = const LoginPage();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          // Subtle background texture or decorations
          Positioned(
            top: -100,
            right: -100,
            child: FadeInDown(
              child: CircleAvatar(
                radius: 150,
                backgroundColor: const Color(0xFF36E27B).withOpacity(0.05),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/sign-language.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Text(
                        'SIGN ACADEMY',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MASTER THE ART OF SIGNING',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF36E27B),
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom loading/status
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 1000),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFF36E27B).withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF36E27B)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

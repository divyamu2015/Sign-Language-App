import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizSuccessScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int xpGained;
  final int gemsGained;

  const QuizSuccessScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.xpGained = 15,
    this.gemsGained = 5,
  });

  @override
  Widget build(BuildContext context) {
    double accuracy = (score / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration Icon
              ZoomIn(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF36E27B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Color(0xFF36E27B),
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Lesson Complete!',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'You\'re making amazing progress!',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'XP GAINED',
                    '+$xpGained',
                    Icons.bolt_rounded,
                    Colors.orange,
                    800,
                  ),
                  _buildStatCard(
                    'GEMS',
                    '+$gemsGained',
                    Icons.diamond_rounded,
                    Colors.blue,
                    1000,
                  ),
                  _buildStatCard(
                    'ACCURACY',
                    '${accuracy.toInt()}%',
                    Icons.gps_fixed_rounded,
                    const Color(0xFF36E27B),
                    1200,
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // Action Button
              FadeInUp(
                delay: const Duration(milliseconds: 1400),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36E27B),
                    foregroundColor: const Color(0xFF112117),
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 8,
                    shadowColor: const Color(0xFF36E27B).withOpacity(0.4),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

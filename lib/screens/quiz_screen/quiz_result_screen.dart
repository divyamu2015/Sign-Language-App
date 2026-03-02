import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../home_screen.dart'; // For AppColors/ClayContainer reuse

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int? xpGained;
  final int? currentXp;
  final bool isError;
  final String? errorMessage;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.xpGained,
    this.currentXp,
    this.isError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    bool isExcellent = score / totalQuestions >= 0.8;
    bool isGood = score / totalQuestions >= 0.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Animated Emoji/Success Indicator
              ZoomIn(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: ClayContainer(
                    width: 140,
                    height: 140,
                    borderRadius: 70,
                    spread: 8,
                    color: isExcellent ? Colors.green.shade50 : (isGood ? Colors.blue.shade50 : Colors.orange.shade50),
                    child: Center(
                      child: Icon(
                        isExcellent ? Icons.emoji_events_rounded : (isGood ? Icons.thumb_up_rounded : Icons.psychology_rounded),
                        size: 70,
                        color: isExcellent ? Colors.green : (isGood ? Colors.blue : Colors.orange),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Outcome Text
              FadeInDown(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  isExcellent ? 'PHENOMENAL!' : (isGood ? 'GREAT JOB!' : 'KEEP GOING!'),
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              FadeInDown(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'Challenge Completed',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Score Card
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: ClayContainer(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 32,
                  spread: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Score', '$score/$totalQuestions', AppColors.primary),
                      Container(width: 2, height: 40, color: AppColors.clayShadow.withOpacity(0.2)),
                      _buildStatItem('XP Gained', xpGained != null ? '+$xpGained' : '-', Colors.green),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (currentXp != null)
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    'Total Mastery XP: $currentXp',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              if (isError)
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Note: $errorMessage\nScore saved locally only.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: Colors.red.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

              const Spacer(),
              
              // Bottom Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    _buildNavButton(
                      context,
                      'BACK TO JOURNEY',
                      Icons.home_rounded,
                      true,
                      () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String label, IconData icon, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        height: 64,
        width: double.infinity,
        borderRadius: 20,
        color: primary ? AppColors.primary : Colors.white,
        spread: 6,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary ? Colors.white : AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: primary ? Colors.white : AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

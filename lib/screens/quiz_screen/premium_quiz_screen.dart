import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signin_language_app/screens/quiz_screen/quiz_success_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../uri_links/links.dart';

class PremiumQuizScreen extends StatefulWidget {
  final int levelId;
  final int userId;
  const PremiumQuizScreen({super.key, required this.levelId, required this.userId});

  @override
  State<PremiumQuizScreen> createState() => _PremiumQuizScreenState();
}

class _PremiumQuizScreenState extends State<PremiumQuizScreen> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;
  int? _selectedOptionId;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _lives = 5;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _userId = widget.userId;
      if (_userId == 0) { // Fallback if 0 is passed
        final prefs = await SharedPreferences.getInstance();
        _userId = prefs.getInt('user_id');
      }
      
      if (_userId == null || _userId == 0) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }
      await _fetchQuestions();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQuestions() async {
    final uri = Uri.parse('${baseUri}userapp/api/levels/${widget.levelId}/questions/').replace(queryParameters: {
      'user_id': _userId.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _questions = data['questions'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load questions';
        _isLoading = false;
      });
    }
  }

  void _handleOptionTap(int optionId, bool isThisCorrect) {
    if (_isAnswered) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedOptionId = optionId;
      _isAnswered = true;
      _isCorrect = isThisCorrect;
      if (_isCorrect) _score++;
      if (!_isCorrect) _lives--;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _isCorrect = false;
        _selectedOptionId = null;
      });
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSuccessScreen(
          score: _score,
          totalQuestions: _questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF36E27B))));
    }
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!, style: GoogleFonts.lexend())));
    }
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: Text('No questions available', style: GoogleFonts.lexend())));
    }

    final currentQuestion = _questions[_currentIndex];
    final options = currentQuestion['options'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildVideoSection(currentQuestion['image']),
                    const SizedBox(height: 30),
                    _buildQuestionTitle(currentQuestion['text']),
                    const SizedBox(height: 30),
                    _buildOptionsGrid(options, currentQuestion['correct_answer']),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL ${widget.levelId}',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} of ${_questions.length}',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF36E27B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: const Color(0xFF36E27B).withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF36E27B)),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF36E27B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFF36E27B), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_lives',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF36E27B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: imageUrl != null && imageUrl.isNotEmpty ? DecorationImage(
          image: NetworkImage(imageUrl.startsWith('http') ? imageUrl : '${baseUri.substring(0, baseUri.length - 1)}$imageUrl'),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 5))
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded,
                size: 48, color: Color(0xFF36E27B)),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildQuestionTitle(String text) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Identify the correct sign representation.',
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(List<dynamic> options, int correctAnswerId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final optionId = option['id'];
        bool isSelected = _selectedOptionId == optionId;
        bool isThisCorrect = optionId == correctAnswerId;
        
        Color borderColor = const Color(0xFFE2E8F0);
        Color bgColor = Colors.white;
        Color textColor = const Color(0xFF334155);
        Color iconColor = const Color(0xFF64748B);

        if (_isAnswered) {
          if (isSelected) {
            if (isThisCorrect) {
              borderColor = const Color(0xFF36E27B);
              bgColor = const Color(0xFF36E27B).withOpacity(0.05);
              textColor = const Color(0xFF0F172A);
              iconColor = const Color(0xFF36E27B);
            } else {
              borderColor = Colors.redAccent;
              bgColor = Colors.redAccent.withOpacity(0.05);
              textColor = Colors.redAccent.shade700;
              iconColor = Colors.redAccent;
            }
          }
        } else if (isSelected) {
          borderColor = const Color(0xFF36E27B);
        }

        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: GestureDetector(
            onTap: () => _handleOptionTap(optionId, isThisCorrect),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: isSelected
                    ? [BoxShadow(color: borderColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isAnswered && isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isThisCorrect ? const Color(0xFF36E27B) : Colors.redAccent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Icon(
                          isThisCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIconForOption(option['text']), color: iconColor, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        option['text'] ?? 'Option',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForOption(String? text) {
    if (text == null) return Icons.help_outline;
    String t = text.toLowerCase();
    if (t.contains('hello')) return Icons.front_hand_rounded;
    if (t.contains('thank')) return Icons.volunteer_activism_rounded;
    if (t.contains('please')) return Icons.back_hand_rounded;
    if (t.contains('goodbye')) return Icons.waves_rounded;
    return Icons.sign_language_rounded;
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAnswered)
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect ? const Color(0xFF36E27B).withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _isCorrect ? const Color(0xFF36E27B).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isCorrect ? const Color(0xFF36E27B) : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCorrect ? Icons.celebration_rounded : Icons.sentiment_very_dissatisfied_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCorrect ? 'Well done!' : 'Not quite...',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isCorrect ? const Color(0xFF112117) : Colors.redAccent.shade700,
                            ),
                          ),
                          Text(
                            _isCorrect ? "You're on a 3-question streak." : "The correct answer was Hello.",
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              color: _isCorrect ? const Color(0xFF36E27B).withAlpha(200) : Colors.redAccent.shade700.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if (!_isAnswered) return;
              _nextQuestion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAnswered ? const Color(0xFF36E27B) : Colors.grey.shade200,
              foregroundColor: _isAnswered ? const Color(0xFF112117) : Colors.grey.shade400,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: _isAnswered ? 8 : 0,
              shadowColor: const Color(0xFF36E27B).withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

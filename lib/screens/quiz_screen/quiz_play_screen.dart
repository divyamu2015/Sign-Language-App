import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/app_config.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizPlayScreen({super.key, required this.quizId, required this.quizTitle});

  @override
  _QuizPlayScreenState createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final QuizService _quizService = QuizService();
  late Future<Quiz> _quizFuture;
  
  int _currentIndex = 0;
  int _score = 0;
  bool _isSubmitting = false;
  int? _userId;
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _quizFuture = _quizService.fetchQuizDetail(widget.quizId);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id') ?? AppConfig.demoUserId;
    });
  }

  /// Backend returns http://localhost:8001/... — replace host with our real baseUri
  String _fixImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    // If it contains localhost or 127.0.0.1, extract just the path and reattach baseUri
    final uri = Uri.tryParse(raw);
    if (uri != null && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return '${AppConfig.baseUri}${uri.path}';
    }
    // Already a full URL (e.g. devtunnels)
    if (raw.startsWith('http')) return raw;
    // Relative path
    return '${AppConfig.baseUri}${raw.startsWith('/') ? raw : '/$raw'}';
  }

  void _handleOptionSelected(Option option) {
    setState(() {
      _selectedOptionId = option.id;
    });
  }

  void _goToNext(List<Question> questions) {
    if (_selectedOptionId == null) return;
    
    // Check if correct
    final currentQuestion = questions[_currentIndex];
    final selectedOption = currentQuestion.options.firstWhere((o) => o.id == _selectedOptionId);
    if (selectedOption.isCorrect) {
      _score++;
    }

    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
      });
    } else {
      _submitQuiz(questions.length);
    }
  }

  Future<void> _submitQuiz(int totalQuestions) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _quizService.submitQuizAnswers(
        widget.quizId,
        _userId ?? AppConfig.demoUserId,
        _score,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              score: _score,
              totalQuestions: totalQuestions,
              xpGained: response.xpGained,
              currentXp: response.currentXp,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              score: _score,
              totalQuestions: totalQuestions,
              isError: true,
              errorMessage: e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 230, 202),
      appBar: AppBar(
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Quiz>(
        future: _quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.questions == null || snapshot.data!.questions!.isEmpty) {
            return const Center(child: Text('No questions available for this quiz.'));
          }

          final questions = snapshot.data!.questions!;
          final question = questions[_currentIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / questions.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Question ${_currentIndex + 1} of ${questions.length}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Question Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          question.text,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (_fixImageUrl(question.image).isNotEmpty)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: _fixImageUrl(question.image),
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.grey),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Options
                ...question.options.map((option) {
                  bool isSelected = _selectedOptionId == option.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _handleOptionSelected(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color.fromARGB(255, 87, 49, 94) : Colors.white,
                        foregroundColor: isSelected ? Colors.white : const Color.fromARGB(255, 87, 49, 94),
                        elevation: isSelected ? 4 : 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.purple.shade100, 
                            width: 1
                          ),
                        ),
                      ),
                      child: Text(
                        option.text,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                // Submission Button
                ElevatedButton(
                  onPressed: _selectedOptionId == null || _isSubmitting 
                      ? null 
                      : () => _goToNext(questions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _currentIndex == questions.length - 1 ? 'FINISH QUIZ' : 'CONTINUE',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

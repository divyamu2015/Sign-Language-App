import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

import '../../config/app_config.dart';
import '../home_screen.dart'; // To reuse ClayContainer and AppColors

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, this.catId = 0, this.catName = ''});
  final int catId;
  final String catName;

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<dynamic> questions = [];
  int _currentIndex = 0;
  final Map<int, int?> _selectedOptions = {};
  bool _answered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final uri = '${AppConfig.baseUri}/api/random-questions/${widget.catId}/';
    try {
      final response = await http.get(Uri.parse(uri), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            questions = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      if (AppConfig.useDemoMode) {
        if (mounted) {
          setState(() {
            questions = [
              {
                "id": 1,
                "text": "Identify this sign",
                "image": null,
                "correct_answer": 1,
                "options": [
                  {"option_number": 1, "text": "Hello", "images": []},
                  {"option_number": 2, "text": "Goodbye", "images": []},
                  {"option_number": 3, "text": "Please", "images": []}
                ]
              }
            ];
            _isLoading = false;
          });
        }
      }
    }
  }

  void _checkAnswer(int selectedOptionNumber) {
    setState(() {
      _selectedOptions[_currentIndex] = selectedOptionNumber;
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClayContainer(
                width: 44,
                height: 44,
                borderRadius: 14,
                spread: 2,
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          widget.catName,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeIn(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: ClayContainer(
                            height: 12,
                            borderRadius: 6,
                            isInner: true,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (questions.isEmpty) ? 0 : (_currentIndex + 1) / questions.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${_currentIndex + 1}/${questions.length}',
                          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Question Card
                    ClayContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (questions[_currentIndex]['image'] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              height: 180,
                              width: double.infinity,
                              child: ClayContainer(
                                isInner: true,
                                borderRadius: 20,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    '${AppConfig.baseUri}${questions[_currentIndex]['image']}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            questions[_currentIndex]['text'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Options
                    ...questions[_currentIndex]['options'].map<Widget>((option) {
                      bool isSelected = _selectedOptions[_currentIndex] == option['option_number'];
                      bool isCorrect = _answered && option['option_number'] == questions[_currentIndex]['correct_answer'];
                      bool isWrong = _answered && isSelected && option['option_number'] != questions[_currentIndex]['correct_answer'];
                      
                      Color cardColor = AppColors.background;
                      if (isCorrect) cardColor = Colors.green.shade50;
                      if (isWrong) cardColor = Colors.red.shade50;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: _answered ? null : () => _checkAnswer(option['option_number']),
                          child: ClayContainer(
                            borderRadius: 20,
                            color: isSelected ? Colors.white : cardColor,
                            spread: isSelected ? 4 : 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  ClayContainer(
                                    width: 32,
                                    height: 32,
                                    borderRadius: 10,
                                    color: isCorrect ? Colors.green : (isWrong ? Colors.red : AppColors.surface),
                                    isInner: true,
                                    child: Center(
                                      child: isCorrect 
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : (isWrong ? const Icon(Icons.close, color: Colors.white, size: 16) : null),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option['text'],
                                      style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 40),
                    
                    // Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentIndex > 0)
                          GestureDetector(
                            onTap: _previousQuestion,
                            child: ClayContainer(
                              width: 130,
                              height: 56,
                              borderRadius: 16,
                              child: Center(
                                child: Text('Previous', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 130),
                        
                        if (_answered)
                          GestureDetector(
                            onTap: _currentIndex < questions.length - 1 
                              ? _nextQuestion 
                              : () => Navigator.pop(context),
                            child: ClayContainer(
                              width: 130,
                              height: 56,
                              borderRadius: 16,
                              color: AppColors.primary,
                              child: Center(
                                child: Text(
                                  _currentIndex < questions.length - 1 ? 'Next' : 'Finish', 
                                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.white)
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

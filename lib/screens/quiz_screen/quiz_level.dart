import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'quiz_page.dart';
import 'package:signin_language_app/config/dev_config.dart';

class QuizScreen extends StatefulWidget {
  final int levelId;

  const QuizScreen({super.key, required this.levelId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;
  Map<int, int?> selectedAnswers = {};
  bool isLoading = true;
  String errorMessage = '';
  PageController pageController = PageController();
  int? userId;
  int currentQuestionIndex = 0;

  // Base API URL
  final String baseUrl = 'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');

      if (userId == null) {
        if (DevConfig.useDemoMode) {
          userId = DevConfig.demoUserId;
        } else {
          setState(() {
            errorMessage = 'User not logged in. Please login first.';
            isLoading = false;
          });
          return;
        }
      }

      // Create URI with query parameters
      final uri = Uri.parse(
              'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp/api/levels/${widget.levelId}/questions/')
          .replace(queryParameters: {
        'user_id': userId.toString(),
      });

      debugPrint('Request URL: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          questions = data['questions'];
          for (var q in questions) {
            selectedAnswers[q['id']] = null;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading questions: $e');
      if (DevConfig.useDemoMode) {
        // Fallback data for working without backend
        setState(() {
          questions = [
            {
              "id": 1,
              "text": "What does this sign represent?",
              "image": null,
              "options": [
                {"option_number": 1, "text": "Letter A", "image": null},
                {"option_number": 2, "text": "Letter B", "image": null},
                {"option_number": 3, "text": "Letter C", "image": null},
                {"option_number": 4, "text": "Letter D", "image": null}
              ]
            },
            {
              "id": 2,
              "text": "Which sign is used for 'Hello'?",
              "image": null,
              "options": [
                {"option_number": 1, "text": "Wave hand", "image": null},
                {"option_number": 2, "text": "Touch forehead", "image": null},
                {"option_number": 3, "text": "Clap hands", "image": null},
                {"option_number": 4, "text": "Point finger", "image": null}
              ]
            }
          ];
          for (var q in questions) {
            selectedAnswers[q['id']] = null;
          }
          isLoading = false;
          errorMessage = ''; // Clear error message since we have fallback
        });
      } else {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _submitAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) throw Exception('User not logged in');

      // Prepare answers payload
      final answers = questions
          .map((q) => {
                'question_id': q['id'],
                'selected_option': selectedAnswers[q['id']] ??
                    0, // Default to 0 if not answered
              })
          .toList();

      final url = Uri.parse('$baseUrl/api/levels/${widget.levelId}/answers/');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'answers': answers,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showResultDialog(result);
      } else {
        throw Exception('Failed to submit answers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting answers: $e');
      if (DevConfig.useDemoMode) {
        // Fallback result for working without backend
        _showResultDialog({
          'status': 'passed',
          'message': 'Great job! You passed the demo quiz.',
          'score': 20,
          'total_score': 100,
          'next_level_id': widget.levelId + 1,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(result['status'] == 'passed' ? 'Success!' : 'Try Again'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result['message']),
            SizedBox(height: 16),
            Text('Score: ${result['score']}'),
            Text('Total Score: ${result['total_score']}'),
            if (result['next_level_id'] != null)
              Text('Next Level: ${result['next_level_id']}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog first
              if (result['total_score'] >= 30) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AnimatedGridScreen(
                      userId: userId!,
                      totalScore: result['total_score'],
                    ),
                  ),
                );
              } else {
                // Navigate back to the quiz screen or home screen if needed
                Navigator.of(context)
                    .pop(); // or replace with your desired navigation
              }
            },
          ),
          TextButton(
            child: Text('Retry'),
            onPressed: () {
              Navigator.of(ctx).pop(); // ✅ Close dialog
              _retryQuiz(); // ✅ Restart the same level
            },
          ),
        ],
      ),
    );
  }

  void _retryQuiz() {
    setState(() {
      selectedAnswers.clear(); // ✅ Clear selected answers
      currentQuestionIndex = 0; // ✅ Reset to first question
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('No Questions')),
        body: Center(child: Text('No questions available for this level')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Level ${widget.levelId} Quiz'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 236, 230, 202),
              Color.fromARGB(255, 238, 226, 203),
              Color.fromARGB(255, 241, 218, 168),
              Color.fromARGB(255, 231, 173, 243),
              Color.fromARGB(255, 245, 176, 239),
              Color.fromARGB(255, 213, 148, 221),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(), // Disable swipe
                itemCount: questions.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (ctx, index) {
                  final question = questions[index];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (question['text'] != null)
                          Text(
                            question['text'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        SizedBox(height: 16),
                        if (question['image'] != null)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://417sptdw-8003.inc1.devtunnels.ms${question['image']}',
                              placeholder: (ctx, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (ctx, url, err) => Icon(Icons.error),
                              fit: BoxFit.contain,
                              height: 200,
                            ),
                          ),
                        SizedBox(height: 24),
                        ...question['options'].map<Widget>((option) {
                          final isSelected = selectedAnswers[question['id']] ==
                              option['option_number'];
                          return Card(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : null,
                            elevation: isSelected ? 4 : 1,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedAnswers[question['id']] =
                                      option['option_number'];
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    if (option['image'] != null)
                                      CachedNetworkImage(
                                        imageUrl:
                                            'https://417sptdw-8003.inc1.devtunnels.ms${option['image']}',
                                        width: 60,
                                        height: 60,
                                        placeholder: (ctx, url) => SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option['text']?.isNotEmpty ?? false
                                            ? option['text']
                                            : 'Option ${option['option_number']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle,
                                          color:
                                              Theme.of(context).primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text('Previous'),
                      ),
                    ),
                  if (currentIndex > 0) SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedAnswers[questions[currentIndex]['id']] ==
                            null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select an answer')),
                          );
                          return;
                        }

                        if (currentIndex < questions.length - 1) {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _submitAnswers();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        currentIndex < questions.length - 1
                            ? 'Next Question'
                            : 'Submit Answers',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

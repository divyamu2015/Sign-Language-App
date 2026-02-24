import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../home_screen.dart';

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
  int? catId;
  String? catName;

  @override
  void initState() {
    super.initState();
    catId = widget.catId;
    catName = widget.catName;
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final uri =
        'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp/random-questions/$catId/';
    // print(uri);
    try {
      final response = await http
          .get(Uri.parse(uri), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        setState(() {
          questions = json.decode(response.body);
        });
        //  print(response);
        // print(response.body);
        // print(response.statusCode);
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error.. ${e.toString()}');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color.fromARGB(255, 87, 49, 94), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(catName!,
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 87, 49, 94))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return HomeScreen();
                  },
                ));
              },
              icon: Icon(
                Icons.home,
                size: 32,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                Color.fromARGB(255, 213, 148, 221),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Question ${_currentIndex + 1}:',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (questions[_currentIndex]['image'] != null &&
                                  questions[_currentIndex]['image'].isNotEmpty)
                                Image.network(
                                  'https://417sptdw-8003.inc1.devtunnels.ms${questions[_currentIndex]['image']}',
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image,
                                          size: 100, color: Colors.red),
                                ),
                              Text(
                                questions[_currentIndex]['text'],
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: questions[_currentIndex]['options']
                            .map<Widget>((option) {
                          return ListTile(
                            leading: Radio<int>(
                              value: option['option_number'],
                              groupValue: _selectedOptions[_currentIndex],
                              onChanged: (int? value) {
                                _checkAnswer(value!);
                              },
                            ),
                            title: option['images'] != null &&
                                    option['images'].isNotEmpty
                                ? Builder(
                                    builder: (context) {
                                      final imageUrl =
                                          option['images'][0]['image'];
                                      debugPrint(
                                          'Options Image URL: https://417sptdw-8003.inc1.devtunnels.ms$imageUrl');

                                      return Image.network(
                                        'https://417sptdw-8003.inc1.devtunnels.ms$imageUrl',
                                        height: 200,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          debugPrint(
                                              'Failed to load image: https://417sptdw-8003.inc1.devtunnels.ms$imageUrl');
                                          return const Icon(Icons.broken_image,
                                              size: 30, color: Colors.red);
                                        },
                                      );
                                    },
                                  )
                                : Text(
                                    option['text'],
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                          );
                        }).toList(),
                      ),
                      if (_answered)
                        if (_answered)
                          Text(
                            _selectedOptions[_currentIndex] ==
                                    questions[_currentIndex]['correct_answer']
                                ? 'Correct!'
                                : 'Wrong! Correct Answer: ${questions[_currentIndex]['options'].firstWhere((option) => option['option_number'] == questions[_currentIndex]['correct_answer'], orElse: () => {
                                      'text': 'Not available'
                                    })['text']}',
                            style: TextStyle(
                              color: _selectedOptions[_currentIndex] ==
                                      questions[_currentIndex]['correct_answer']
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed:
                                _currentIndex > 0 ? _previousQuestion : null,
                            child: const Text('Previous'),
                          ),
                          ElevatedButton(
                            onPressed: _currentIndex < questions.length - 1
                                ? _nextQuestion
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

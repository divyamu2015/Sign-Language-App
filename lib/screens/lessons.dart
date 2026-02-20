import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.catId, required this.catName});
  final int catId;
  final String catName;
  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<dynamic> vocabulary = [];
  int? catid;
  String? catName;

  @override
  void initState() {
    super.initState();
    catid = widget.catId;
    catName = widget.catName;
    fetchVocabulary();
  }

  Future<void> fetchVocabulary() async {
    final response = await http.get(Uri.parse(
        'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp/categories/$catid/lessons/'));
    if (response.statusCode == 200) {
      setState(() {
        vocabulary = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load vocabulary');
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  // void _markAsLearned() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Lesson marked as learned!")),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          catName!,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 87, 49, 94),
          ),
        ),
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
      body: Container(
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
        child: vocabulary.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: vocabulary.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: Card(
                              key: ValueKey<int>(_currentIndex),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      vocabulary[index]["name"],
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    SizedBox(height: 20),
                                    CachedNetworkImage(
                                      imageUrl:
                                          'https://417sptdw-8003.inc1.devtunnels.ms' +
                                              vocabulary[index]["image"],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      height: 200,
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        vocabulary[index]["description"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: _previousPage,
                      ),
                      if (_currentIndex < vocabulary.length - 1)
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                          onPressed: () {
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          },
                        ),
                      // if (_currentIndex == vocabulary.length - 1)
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       Navigator.push(context, MaterialPageRoute(
                      //         builder: (context) {
                      //           return PracticePage(
                      //             catId: catid!,
                      //             catName: catName!,
                      //           );
                      //         },
                      //       ));
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor:
                      //           const Color.fromARGB(255, 103, 153, 145),
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 32, vertical: 16),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       elevation: 5,
                      //     ),
                      //     child: Text(
                      //       "Let's Practice",
                      //       style: TextStyle(
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.white),
                      //     ),
                      //   ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}

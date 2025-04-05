import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import '../../uri_links/links.dart';
import 'quiz_level.dart';
import 'view_rewards.dart';

class AnimatedGridScreen extends StatefulWidget {
  const AnimatedGridScreen(
      {super.key, required this.userId, this.totalScore = 0});
  final int userId;
  final int totalScore;

  @override
  _AnimatedGridScreenState createState() => _AnimatedGridScreenState();
}

class _AnimatedGridScreenState extends State<AnimatedGridScreen> {
  List<dynamic> data = [];
  int? userId;
  int userScore = 0;
  final int unlockScore = 30;
  int? totalScore;
  double rating = 0;
  bool showLevelPassedDialog = false;
  int count = 0;

  void updateScore(int score) {
    setState(() {
      userScore = score;
    });
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    totalScore = widget.totalScore;
    print('From quizleve page===============$totalScore');
    _loadUserScore();
    quizLevel();
    checkAndShowLevelPassedDialog();
    Future.delayed(Duration.zero, () {
      if (widget.totalScore > 0) {
        setState(() {
          showLevelPassedDialog = true;
        });
      }
    });
  }

  Future<void> _loadUserScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userScore = prefs.getInt('total_score') ?? 0; // ✅ Fetch latest score
    });
    print('UserScore========$userScore');
  }

  Future<void> quizLevel() async {
    final uri = Uri.parse(getLevels);
    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
      } else {
        throw 'Datas are not found';
      }
    } catch (e) {
      throw 'Exception is ${e.toString()}';
    }
  }

  Future<void> checkAndShowLevelPassedDialog() async {
    int levelsCompleted = totalScore! ~/ unlockScore; // ✅ Levels completed
    if (totalScore! >= unlockScore && !showLevelPassedDialog) {
      setState(() {
        showLevelPassedDialog = true;
      });

      await Future.delayed(Duration.zero);
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/rewards.JPG', height: 100),
                  SizedBox(height: 10),
                  Text(
                    'Level Passed!',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // ✅ Close dialog
                      setState(() {
                        count = levelsCompleted * 8;
                        showLevelPassedDialog = false;
                      });
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //     onPressed: () {
          //       // Navigator.push(context, MaterialPageRoute(
          //       //   builder: (context) {
          //       //     return DancingDoll();
          //       //   },
          //       // ));
          //     },
          //     icon: Icon(Icons.arrow_back)),
          title: Text(
            'Breaking Barriers',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 87, 49, 94),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // centerTitle: true,
          actions: [
            Row(
              children: [
                Image.asset(
                  'assets/images/dollar.png',
                  height: 40,
                  width: 40,
                ),
                Text(
                  '+$count',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                // const SizedBox(
                //   width: 5,
                // )
                // Icon(
                //   Icons.circle,
                //   color: Colors.amber,
                // )
              ],
            )
          ],
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimationLimiter(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: data.length, // Use data length
                      itemBuilder: (context, index) {
                        int levelsPassed = totalScore! ~/
                            30; // ✅ Count how many levels are passed
                        bool isLocked = index >
                            levelsPassed; // ✅ First level is always unlocked

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: Duration(milliseconds: 500),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: isLocked
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QuizScreen(
                                              levelId: data[index]
                                                  ['id'], // Pass the level ID
                                            ),
                                          ),
                                        );
                                        _loadUserScore();
                                      },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(15)),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$baseUri${data[index]['icon']}',
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                      color: Colors.white),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RatingBar.builder(
                                              onRatingUpdate: (ratingValue) {
                                                setState(() {
                                                  rating = ratingValue;
                                                });
                                              },
                                              initialRating: 0,
                                              itemBuilder: (context, index) =>
                                                  Icon(Icons.star,
                                                      color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isLocked)
                                        Positioned.fill(
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            child: Center(
                                              child: Icon(Icons.lock,
                                                  color: Colors.white,
                                                  size: 40),
                                            ),
                                          ),
                                        ),
                                      // if (showLevelPassedDialog)
                                      //   Center(
                                      //     child: Container(
                                      //       padding: EdgeInsets.all(20),
                                      //       decoration: BoxDecoration(
                                      //         color: Colors.white,
                                      //         borderRadius: BorderRadius.circular(20),
                                      //       ),
                                      //       child: Column(
                                      //         mainAxisSize: MainAxisSize.min,
                                      //         children: [
                                      //           Image.asset(
                                      //               'assets/images/rewards.JPG',
                                      //               height: 100),
                                      //           SizedBox(height: 10),
                                      //           Text('Level Passed!',
                                      //               style: GoogleFonts.poppins(
                                      //                   fontSize: 18,
                                      //                   fontWeight: FontWeight.bold)),
                                      //           SizedBox(height: 10),
                                      //           ElevatedButton(
                                      //             onPressed: () {
                                      //               setState(() {
                                      //                 showLevelPassedDialog = false;
                                      //               });
                                      //             },
                                      //             child: Text('OK'),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 138, 83),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRewards(
                            count: count,
                            totalScore: totalScore!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "View Reward",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

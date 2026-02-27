import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'home_screen.dart'; // To reuse ClayContainer and AppColors

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.catId, required this.catName, this.initialIndex = 0});
  final int catId;
  final String catName;
  final int initialIndex;
  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<dynamic> vocabulary = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    fetchVocabulary();
  }

  Future<void> fetchVocabulary() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUri}/userapp/categories/${widget.catId}/lessons/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            vocabulary = json.decode(response.body);
            _isLoading = false;
          });
          if (widget.initialIndex > 0 && vocabulary.length > widget.initialIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.jumpToPage(widget.initialIndex);
            });
          }
        }
      } else {
        throw Exception('Failed to load vocabulary');
      }
    } catch (e) {
      if (AppConfig.useDemoMode) {
        if (mounted) {
          setState(() {
            if (widget.catName.toLowerCase().contains('alphabet')) {
              vocabulary = List.generate(26, (index) => {
                "id": index + 1,
                "name": String.fromCharCode(65 + index),
                "description": "Learn to sign '${String.fromCharCode(65 + index)}'"
              });
            } else {
              vocabulary = [
                {"id": 1, "name": "Hello", "description": "A polite greeting"},
                {"id": 2, "name": "Thank You", "description": "Express gratitude"},
                {"id": 3, "name": "Please", "description": "A polite request"},
                {"id": 4, "name": "Help", "description": "Ask for assistance"},
              ];
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                child: ClayContainer(
                  width: 44,
                  height: 44,
                  borderRadius: 14,
                  spread: 2,
                  child: const Icon(Icons.home_rounded, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : vocabulary.isEmpty
              ? Center(child: Text('No lessons available.', style: GoogleFonts.lexend(fontSize: 18, color: AppColors.textSecondary)))
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _pageController,
                        itemCount: vocabulary.length,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        itemBuilder: (context, index) {
                          final item = vocabulary[index];
                          final String? imageUrl = item["image"];
                          final String name = item["name"] ?? item["lesson_name"] ?? 'Sign';
                          final String? desc = item["description"];

                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: FadeInDown(
                              child: ClayContainer(
                                borderRadius: 40,
                                spread: 12,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(32),
                                          child: imageUrl != null && imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: imageUrl.startsWith('http')
                                                      ? imageUrl
                                                      : '${AppConfig.baseUri}${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}',
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded, size: 64, color: AppColors.clayShadow),
                                                )
                                              : const Icon(Icons.image_not_supported_rounded, size: 80, color: AppColors.clayShadow),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              name,
                                              style: GoogleFonts.lexend(
                                                fontSize: 42,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              desc ?? 'Slowly move your fingers to form this symbol.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.lexend(
                                                fontSize: 16,
                                                color: AppColors.textSecondary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              vocabulary.length > 5 ? 5 : vocabulary.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentIndex % 5 == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex % 5 == index ? AppColors.primary : AppColors.clayShadow.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              int currentProgress = prefs.getInt('cat_progress_${widget.catId}') ?? 0;
                              if (_currentIndex >= currentProgress) {
                                await prefs.setInt('cat_progress_${widget.catId}', _currentIndex + 1);
                              }

                              if (_currentIndex < vocabulary.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOutQuart,
                                );
                              } else {
                                Navigator.pop(context, true);
                              }
                            },
                            child: ClayContainer(
                              height: 64,
                              color: AppColors.primary,
                              borderRadius: 20,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentIndex < vocabulary.length - 1 ? 'LEARNED! NEXT' : 'FINISH MODULE',
                                      style: GoogleFonts.lexend(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SignDictionaryScreen extends StatefulWidget {
  const SignDictionaryScreen({super.key});

  @override
  State<SignDictionaryScreen> createState() => _SignDictionaryScreenState();
}

class _SignDictionaryScreenState extends State<SignDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _giphyApiKey = 'YOUR_GIPHY_API_KEY'; // User will need to add theirs, or I'll provide a placeholder logic
  List<dynamic> _results = [];
  bool _isSearching = false;
  String? _errorMessage;

  // Pre-defined suggestions for better UX
  final List<String> _suggestions = ['Hello', 'Thank You', 'Please', 'Excuse Me', 'Help', 'Eat', 'Water', 'Family', 'Love'];

  Future<void> _searchSign(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Use the Giphy API to search specifically for ASL signs
      // We append "ASL" or "Sign Language" to ensure we get relevant results
      final response = await http.get(
        Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=dc6zaTOxFJmzC&q=asl+$query&limit=10&rating=g'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _results = data['data'];
          if (_results.isEmpty) {
            _errorMessage = 'No signs found for "$query". Try a simpler word!';
          }
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error connecting to the dictionary. Please try again.';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Make sure you are connected to the internet!';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sign Dictionary',
          style: GoogleFonts.lexend(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: FadeInDown(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchSign,
                  decoration: InputDecoration(
                    hintText: 'Search for a word (e.g. "Apple")',
                    hintStyle: GoogleFonts.lexend(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF36E27B)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF36E27B)),
                      onPressed: () => _searchSign(_searchController.text),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // Suggestions
          if (_results.isEmpty && !_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Suggestions',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _suggestions.map((word) => _buildSuggestionChip(word)).toList(),
                  ),
                ],
              ),
            ),

          // Results Area
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF36E27B)))
                : _errorMessage != null
                    ? _buildErrorView()
                    : _results.isEmpty
                        ? _buildEmptyState()
                        : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String word) {
    return GestureDetector(
      onTap: () {
        _searchController.text = word;
        _searchSign(word);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF36E27B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF36E27B).withOpacity(0.3)),
        ),
        child: Text(
          word,
          style: GoogleFonts.lexend(
            color: const Color(0xFF36E27B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Type a word above to see its sign!',
            style: GoogleFonts.lexend(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded, size: 60, color: Colors.orangeAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(color: const Color(0xFF0F172A), fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _searchSign(_searchController.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF36E27B)),
            child: const Text('Try Again'),
          )
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final gif = _results[index];
        final url = gif['images']['fixed_height']['url'];
        final title = gif['title'].toString().replaceAll('ASL', '').replaceAll('GIF', '').trim();

        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    url,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF36E27B).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sign_language, color: Color(0xFF36E27B), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title.isEmpty ? _searchController.text.toUpperCase() : title,
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
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
      },
    );
  }
}

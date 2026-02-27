import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/app_config.dart';

// Reuse AppColors but refine for Dictionary context
class DicColors {
  static const Color primary = Color(0xFFEE8C2B); // Orange from HTML
  static const Color background = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color groove = Color(0xFFCBD5E1);
}

class SignDictionaryScreen extends StatefulWidget {
  const SignDictionaryScreen({super.key});

  @override
  State<SignDictionaryScreen> createState() => _SignDictionaryScreenState();
}

class _SignDictionaryScreenState extends State<SignDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _giphyApiKey = dotenv.env['GIPHY_API_KEY'] ?? 'dc6zaTOxFJmzC'; 
  List<dynamic> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _activeCategory = 'All Signs';

  final List<String> _categories = ['All Signs', 'Common', 'Animals', 'Feelings'];

  @override
  void initState() {
    super.initState();
    // Default search to show something
    _searchSign('Hello');
  }

  Future<void> _searchSign(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Improved query for strictly ASL content
      final searchQuery = Uri.encodeComponent('asl $query sign language');
      final url = 'https://api.giphy.com/v1/gifs/search?api_key=$_giphyApiKey&q=$searchQuery&limit=25&rating=g';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allGifs = data['data'];
        
        // Filter results to ensure they are actually ASL signs
        final filteredGifs = allGifs.where((gif) {
          final title = gif['title'].toString().toLowerCase();
          final username = gif['username'].toString().toLowerCase();
          return title.contains('asl') || 
                 title.contains('sign') || 
                 username.contains('signwithrobert') ||
                 username.contains('asl');
        }).toList();

        setState(() {
          _results = filteredGifs.isEmpty ? (allGifs.length > 5 ? allGifs.take(8).toList() : allGifs) : filteredGifs;
          if (_results.isEmpty) {
            _errorMessage = 'No ASL signs found for "$query"';
          }
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Dictionary service busy. Try again!';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Check your connection!';
        _isSearching = false;
      });
    }
  }

  void _showBigScreen(dynamic gif) {
    final highResUrl = gif['images']['original']['url'];
    final title = gif['title'].toString().replaceAll('ASL', '').replaceAll('GIF', '').trim();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: gif['id'],
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white, width: 8),
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 40, spreadRadius: 10),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(highResUrl, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        child: Text(
                          title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.splineSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'AMERICAN SIGN LANGUAGE',
                          style: GoogleFonts.splineSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DicColors.primary,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DicColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilters(),
            Expanded(
              child: _isSearching 
                  ? const Center(child: CircularProgressIndicator(color: DicColors.primary))
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildResultsGrid(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ClayCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            'Sign Explorer',
            style: GoogleFonts.splineSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: DicColors.textMain,
            ),
          ),
          _ClayCircleButton(
            icon: Icons.settings_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: DicColors.groove,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: DicColors.textMuted, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchSign,
                style: GoogleFonts.splineSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DicColors.textMain,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for signs...',
                  hintStyle: GoogleFonts.splineSans(color: DicColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isActive = _activeCategory == _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeCategory = _categories[index]);
                _searchSign(_categories[index] == 'All Signs' ? 'Hello' : _categories[index]);
              },
              child: _ClayFilterButton(
                label: _categories[index],
                isActive: isActive,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 30,
        crossAxisSpacing: 25,
        childAspectRatio: 0.8,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final gif = _results[index];
        final url = gif['images']['fixed_height']['url'];
        final title = gif['title'].toString().replaceAll('ASL', '').replaceAll('GIF', '').trim();
        
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: _SignCard(
            id: gif['id'],
            imageUrl: url,
            title: title.isEmpty ? _searchController.text.toUpperCase() : title,
            tags: const ['ASL', 'Verified'],
            onTap: () => _showBigScreen(gif),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 80, color: DicColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: GoogleFonts.splineSans(fontSize: 18, color: DicColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by ',
            style: GoogleFonts.splineSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: DicColors.textMuted,
              letterSpacing: 2.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: DicColors.groove,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'GIPHY',
              style: GoogleFonts.splineSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: DicColors.textMuted,
                letterSpacing: -1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Support Widgets ─────────────────────────────────────────────────────────

class _ClayCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ClayCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: DicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(icon, color: DicColors.textMain, size: 28),
      ),
    );
  }
}

class _ClayFilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  const _ClayFilterButton({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? DicColors.primary : DicColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isActive ? const Color(0xFFFF9D42) : Colors.white,
          width: 3,
        ),
        boxShadow: isActive 
          ? [
              BoxShadow(
                color: DicColors.primary.withOpacity(0.3),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
              const BoxShadow(
                color: Colors.white24,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-6, -6),
                blurRadius: 12,
              ),
            ],
      ),
      child: Text(
        label,
        style: GoogleFonts.splineSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.white : DicColors.textMuted,
        ),
      ),
    );
  }
}

class _SignCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;

  const _SignCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(12, 12),
              blurRadius: 24,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-8, -8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DicColors.groove,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(-4, -4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Hero(
                    tag: id,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.splineSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DicColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tags.map((t) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: t == 'ASL' ? DicColors.primary.withOpacity(0.1) : DicColors.background,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        t,
                        style: GoogleFonts.splineSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: t == 'ASL' ? DicColors.primary : DicColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    )).toList(),
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

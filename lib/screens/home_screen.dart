import 'dart:math';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

import 'category_page/category_view/category_view.dart';
import 'home_page/alphabetics_page.dart';
import 'home_page/numbers_pages.dart';
import 'pratice_screen/practice_home.dart';
import 'quiz_screen/quiz_page.dart';
import 'profile_manage.dart';
import 'faq_screen.dart';
import 'about_quiz.dart';
import '../authentication_screen/login_screen/login_view/login_page.dart';
import 'modules_catalog_screen.dart';
import 'learning_path_screen.dart';
import 'lessons.dart';
import 'sign_dictionary_screen.dart';
import 'quiz_screen/global_quizzes_screen.dart';
import 'ai_camera_screen.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  static const Color primary = Color(0xFF13A4EC);
  static const Color background = Color(0xFFF0F4F8);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color green = Color(0xFF4ADE80);
  static const Color purple = Color(0xFFA855F7);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color clayShadow = Color(0xFFA3B1C6);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
}

// ─── Claymorphism Container ──────────────────────────────────────────────────
class ClayContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double spread;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isInner;

  const ClayContainer({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 32,
    this.spread = 8,
    this.width,
    this.height,
    this.padding,
    this.isInner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isInner
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(4, 4),
                blurRadius: 10,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 10,
              ),
            ]
          : [
              BoxShadow(
                color: AppColors.clayShadow.withOpacity(0.4),
                offset: Offset(spread, spread),
                blurRadius: spread * 2,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 12,
              ),
            ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.02)!,
          ],
        ),
      ),
      child: child,
    );
  }
}

// ─── Clay Liquid Progress Bar ────────────────────────────────────────────────
class ClayLiquidProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;

  const ClayLiquidProgress({
    super.key,
    required this.progress,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Liquid Fill
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCirc,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(color, Colors.white, 0.4)!,
                      color,
                      Color.lerp(color, Colors.black, 0.2)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Reflection
                    Positioned(
                      top: 4,
                      left: 12,
                      child: Container(
                        width: constraints.maxWidth * progress * 0.3,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Home Screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userId = 0, this.userName = ''});
  final int userId;
  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  String _fetchedUserName = '';
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchCategories();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First, try to get from SharedPreferences as immediate fallback
    String? localName = prefs.getString('user_name');
    if (localName != null && mounted) {
      setState(() => _fetchedUserName = localName);
    }

    // Then try to fetch fresh data from API
    int targetId = widget.userId;
    if (targetId == 0) {
      targetId = prefs.getInt('user_id') ?? 0;
    }

    if (targetId == 0) return;

    final uri = Uri.parse(AppConfig.viewProfileUri(targetId));
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Check multiple common name fields
            _fetchedUserName = data['username'] ?? data['name'] ?? data['full_name'] ?? _fetchedUserName;
          });
          // Update local cache
          if (_fetchedUserName.isNotEmpty) {
            await prefs.setString('user_name', _fetchedUserName);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(AppConfig.categoriesUri),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dynamic rawData = jsonDecode(response.body);
        List<dynamic> data = [];
        
        if (rawData is List) {
          data = rawData;
        } else if (rawData is Map) {
          data = rawData['results'] ?? rawData['data'] ?? rawData['categories'] ?? [];
        }

        final prefs = await SharedPreferences.getInstance();
        
        // Merge with local progress
        for (var cat in data) {
          final dynamic rawId = cat['id'];
          final int catId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
          int localCount = prefs.getInt('cat_progress_$catId') ?? 0;
          if (localCount > 0 && (cat['progress'] == null || cat['progress'] == 0)) {
            cat['progress'] = (localCount * 10).clamp(0, 100); 
          }
        }

        if (mounted) {
          setState(() {
            _categories = data;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.useDemoMode) {
        final prefs = await SharedPreferences.getInstance();
        if (mounted) {
          setState(() {
            _categories = [
              {
                'id': 1, 
                'title': 'Alphabet', 
                'progress': ((prefs.getInt('cat_progress_1') ?? 0) / 26 * 100).toInt().clamp(0, 100), 
                'icon': Icons.font_download_rounded, 
                'color': Colors.blue.shade50
              },
              {
                'id': 2, 
                'title': 'Greetings', 
                'progress': ((prefs.getInt('cat_progress_2') ?? 0) / 10 * 100).toInt().clamp(0, 100), 
                'icon': Icons.front_hand_rounded, 
                'color': Colors.green.shade50
              },
              {
                'id': 3, 
                'title': 'Family', 
                'progress': ((prefs.getInt('cat_progress_3') ?? 0) / 5 * 100).toInt().clamp(0, 100), 
                'icon': Icons.people_rounded, 
                'color': Colors.purple.shade50
              },
              {
                'id': 4, 
                'title': 'Numbers', 
                'progress': ((prefs.getInt('cat_progress_4') ?? 0) / 10 * 100).toInt().clamp(0, 100), 
                'icon': Icons.lock_rounded, 
                'color': Colors.grey.shade100, 
                'isLocked': true
              },
            ];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load modules: $e')),
          );
        }
        debugPrint('Error fetching categories: $e');
      }
    }
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex) return;
    
    switch (index) {
      case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => const SignDictionaryScreen())); break;
      case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalQuizzesScreen())); break;
      case 3: Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfManage(userId: widget.userId))); break;
      default: setState(() => _selectedNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                _fetchUserProfile();
                _fetchCategories();
              },
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStreakCard()),
                  SliverToBoxAdapter(child: _buildDailyGoal()),
                  SliverToBoxAdapter(child: _buildQuizBanner()),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    sliver: _buildCategoryGrid(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String name = _fetchedUserName.isNotEmpty ? _fetchedUserName : (widget.userName.isNotEmpty ? widget.userName : 'Alex');
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClayContainer(
                  width: 68,
                  height: 68,
                  borderRadius: 24,
                  spread: 4,
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=$name',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASTER LEVEL',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary.withOpacity(0.7),
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      '$name! 👋',
                      style: GoogleFonts.lexend(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ClayContainer(
              width: 54,
              height: 54,
              borderRadius: 18,
              spread: 3,
              child: const Icon(Icons.notifications_rounded, color: AppColors.clayShadow, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ClayContainer(
          height: 130,
          color: AppColors.orange,
          spread: 12,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'STREAK',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '15 DAYS',
                          style: GoogleFonts.lexend(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Hot Progress!',
                                style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Hero(
                      tag: 'fire_streak',
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 80,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoal() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '65%',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ClayLiquidProgress(progress: 0.65),
          const SizedBox(height: 12),
          Text(
            'Almost there, molded to perfection!',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GlobalQuizzesScreen()),
          );
        },
        child: ClayContainer(
          height: 90,
          color: AppColors.purple,
          spread: 8,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.psychology_rounded, color: Colors.white, size: 40),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READY FOR A CHALLENGE?',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Take a Global Quiz!',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_isLoading) {
      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cat = _categories[index];
          final dynamic rawId = cat['id'];
          final int catId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
          
          // Re-map backend keys if necessary
          String title = cat['category_name'] ?? cat['name'] ?? cat['title'] ?? 'Module';
          int progressValue = cat['progress'] ?? 0;
          
          // --- Force Unlock Only Alphabets and Numbers ---
          String t = title.toLowerCase();
          bool isLocked = false; // All categories are unlocked in this version
          
          // Determine icon and color based on title or index
          IconData icon = Icons.sign_language_rounded;
          Color bgColor = Colors.white;
          
          if (cat['icon'] is IconData) {
            icon = cat['icon'];
            bgColor = cat['color'] ?? Colors.white;
          } else {
            // Re-map common categories
            if (t.contains('alphabet') || t.contains('alfabet')) { 
              icon = Icons.font_download_rounded; 
              bgColor = Colors.blue.shade50; 
            }
            else if (t.contains('greet')) { icon = Icons.front_hand_rounded; bgColor = Colors.green.shade50; }
            else if (t.contains('family')) { icon = Icons.people_rounded; bgColor = Colors.purple.shade50; }
            else if (t.contains('number')) { icon = Icons.numbers_rounded; bgColor = Colors.orange.shade50; }
          }

          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonPage(
                      catId: catId,
                      catName: title,
                    ),
                  ),
                ).then((_) => _fetchCategories()); // Refresh when back
              },
              child: Opacity(
                opacity: isLocked ? 0.6 : 1.0,
                child: ClayContainer(
                  spread: 6,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClayContainer(
                        width: 80,
                        height: 80,
                        borderRadius: 28,
                        color: bgColor,
                        spread: 0,
                        isInner: true,
                        child: Center(
                          child: cat['icon'] is String && (cat['icon'] as String).isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: (cat['icon'] as String).startsWith('http') 
                                      ? cat['icon'] 
                                      : '${AppConfig.baseUri}${cat['icon'].startsWith('/') ? cat['icon'] : '/${cat['icon']}'}',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => Icon(icon, color: Colors.grey, size: 38),
                                ),
                              )
                            : Icon(
                                icon,
                                color: isLocked ? Colors.grey : Color.lerp(bgColor, Colors.black, 0.45),
                                size: 38,
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked ? 'Locked' : '$progressValue% Done',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 6,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.clayShadow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressValue / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: _categories.length,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClayContainer(
        height: 80,
        borderRadius: 24,
        spread: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.menu_book_rounded, 'Ask Me'),
            _buildNavItem(2, Icons.fitness_center_rounded, 'Quiz'),
            _buildNavItem(3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.clayShadow,
              size: 26,
            ),
            if (isSelected)
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

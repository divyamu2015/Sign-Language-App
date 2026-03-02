import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'quiz_screen/premium_quiz_screen.dart';
import '../config/app_config.dart';
import 'home_screen.dart';
import 'pratice_screen/practice_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_manage.dart';
import 'lessons.dart';
import 'ai_camera_screen.dart';

class LearningPathScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final int userId;

  const LearningPathScreen({
    super.key, 
    this.title = 'Path',
    required this.categoryId,
    required this.userId,
  });

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  int _selectedNavIndex = 0;
  int _completedIndex = 0; // Tracks real progress

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedIndex = prefs.getInt('cat_progress_${widget.categoryId}') ?? 0;
    });
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex && index == 0) return;
    
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0: // Home
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1: // Practice
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PracCategoryScreen(
              catName: 'Practice',
              userId: widget.userId,
            ),
          ),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfManage(userId: widget.userId),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      final response = await http.get(
        Uri.parse(AppConfig.getLessonsUri(widget.categoryId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          if (data is List) {
            _lessons = data;
          } else if (data is Map && data.containsKey('lessons')) {
            _lessons = data['lessons'] ?? [];
          } else if (data is Map && data.containsKey('results')) {
            _lessons = data['results'] ?? [];
          } else {
            _lessons = [];
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      if (AppConfig.useDemoMode) {
        // Fallback data for working without backend
        setState(() {
          if (widget.title.toLowerCase().contains('alphabet')) {
            // Generate A-Z for Alphabet path
            _lessons = List.generate(26, (index) => {
              "id": index + 1,
              "name": String.fromCharCode(65 + index), // A, B, C...
              "description": "Learn to sign '${String.fromCharCode(65 + index)}'"
            });
          } else {
            _lessons = [
              {"id": 1, "name": "Introduction", "description": "Basic introduction to the topic"},
              {"id": 2, "name": "Basic Signs", "description": "Learn the most common signs"},
              {"id": 3, "name": "Common Phrases", "description": "Useful phrases for daily life"},
              {"id": 4, "name": "Advanced Practice", "description": "Refine your skills"},
              {"id": 5, "name": "Final Review", "description": "Test everything you learned"}
            ];
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLessons,
        color: const Color(0xFF36E27B),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeaderContent(), // This now contains the streak, XP, and progress bar
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6DE00F)))
                      : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          _buildPathLine(),
                          _buildNodes(),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
              _buildDecorativeElements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: const Color(0xFF6DE00F).withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFF6DE00F), size: 32),
                  const SizedBox(width: 8),
                  Text(
                    '7 Day Streak',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF182210),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF8B5CF6), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '1,240 XP',
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${((_completedIndex / (_lessons.isEmpty ? 1 : _lessons.length)) * 100).toInt()}% Complete',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6DE00F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _lessons.isEmpty
                      ? 0
                      : (_completedIndex / _lessons.length),
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6DE00F)),
                  minHeight: 12,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPathLine() {
    return Positioned(
      top: 0,
      bottom: 0,
      width: 12,
      child: CustomPaint(
        painter: DashedPathPainter(),
      ),
    );
  }

  Widget _buildNodes() {
    if (_lessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text('No lessons found for this path.', style: GoogleFonts.spaceGrotesk()),
        ),
      );
    }

    // For Alphabets, we want a clear A-Z progression.
    final lessonsToDisplay = _lessons;

    return Center(
      child: Column(
        children: lessonsToDisplay.asMap().entries.map((entry) {
          int index = entry.key;
          var lesson = entry.value;

          // Zig-zag horizontal offset (reduced for better mobile fit)
          double offset = 0;
          int cycle = index % 4;
          if (cycle == 1) offset = -40;
          if (cycle == 3) offset = 40;
          // 0 and 2 are middle

          // Progression Logic based on local storage
          bool isCompleted = index < _completedIndex; 
          bool isActive = index == _completedIndex;
          bool isLocked = index > _completedIndex;

          String nodeText = lesson['name'] ?? lesson['lesson_name'] ?? '';
          String label = nodeText;
          String bubbleDisplay = '';

          // If it's a single letter (Alphabet path)
          if (nodeText.length == 1) {
            bubbleDisplay = nodeText;
            label = "Letter $nodeText";
          } else if (nodeText.toLowerCase().contains('letter ') && nodeText.length <= 8) {
            // "Letter A" -> "A"
            bubbleDisplay = nodeText.split(' ').last;
          } else {
            // Default to empty so the play icon shows, or use first char?
            // Let's use first char if it's a short word, else empty (arrow fallback)
            if (nodeText.isNotEmpty && nodeText.length <= 3) bubbleDisplay = nodeText;
          }

          return Column(
            children: [
              _buildPathNode(
                label: label,
                bubbleContent: bubbleDisplay,
                isActive: isActive,
                isCompleted: isCompleted,
                isLocked: isLocked,
                offset: offset,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LessonPage(
                            catId: widget.categoryId, 
                            catName: widget.title,
                            initialIndex: index,
                        )),
                  );
                  // Refresh progress when coming back
                  if (result == true || result == null) {
                    _loadProgress();
                  }
                },
              ),
              const SizedBox(height: 50),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPathNode({
    required String label,
    required String bubbleContent,
    bool isCompleted = false,
    bool isLocked = false,
    bool isActive = false,
    double offset = 0,
    VoidCallback? onTap,
  }) {
    return Transform.translate(
      offset: Offset(offset, 0),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Column(
          children: [
            if (isActive)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Text(
                  'JUMP IN!',
                  style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            GestureDetector(
              onTap: isLocked ? null : (onTap ?? () {}),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isActive) _PulseEffect(),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFFE2E8F0)
                          : isCompleted
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                      border: Border(
                        bottom: BorderSide(
                          color: isLocked
                              ? const Color(0xFFCBD5E1)
                              : isCompleted
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF7C3AED),
                          width: 8,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (bubbleContent.isNotEmpty)
                            Text(
                              bubbleContent,
                              style: GoogleFonts.spaceGrotesk(
                                color: isLocked ? Colors.white.withOpacity(0.3) : Colors.white, 
                                fontSize: bubbleContent.length > 2 ? 18 : 42, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          if (isLocked)
                            Icon(Icons.lock_rounded, 
                                color: Colors.white.withOpacity(0.8), 
                                size: bubbleContent.isNotEmpty ? 24 : 32)
                          else if (isCompleted)
                            Transform.translate(
                              offset: const Offset(15, 15),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Color(0xFFFBBF24), size: 16, weight: 1000),
                              ),
                            )
                          else if (bubbleContent.isEmpty)
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLocked ? const Color(0xFF94A3B8) : (isActive ? const Color(0xFF8B5CF6) : const Color(0xFFFBBF24)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 16, left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: _selectedNavIndex == 0,
              onTap: () => _onNavTapped(0),
            ),
            _BottomNavItem(
              icon: Icons.fitness_center_rounded,
              label: 'Practice',
              isActive: _selectedNavIndex == 1,
              onTap: () => _onNavTapped(1),
            ),
            // Camera FAB
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiCameraScreen()),
                );
              },
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF36E27B), Color(0xFF2DB361)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF36E27B).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF112117), size: 28),
                ),
              ),
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: _selectedNavIndex == 4,
              onTap: () => _onNavTapped(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 200,
            right: 20,
            child: _FloatingElement(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF6DE00F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6DE00F).withOpacity(0.2), width: 2),
                ),
                child: const Center(child: Text('A', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6DE00F)))),
              ),
            ),
          ),
          Positioned(
            top: 400,
            left: 20,
            child: _FloatingElement(
              reverse: true,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2), width: 2),
                ),
                child: const Icon(Icons.front_hand_rounded, color: Color(0xFF8B5CF6), size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingElement extends StatefulWidget {
  final Widget child;
  final bool reverse;
  const _FloatingElement({required this.child, this.reverse = false});

  @override
  State<_FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<_FloatingElement> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: widget.reverse ? -20 : 20).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: Transform.rotate(
            angle: (_animation.value / 100),
            child: widget.child),
      ),
    );
  }
}

class _PulseEffect extends StatefulWidget {
  @override
  State<_PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<_PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: (1.0 - _controller.value).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 1.0 + (_controller.value * 0.8),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.5),
                width: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _BottomNavItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF36E27B) : const Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF36E27B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDAE8CF)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    double dashHeight = 15;
    double dashSpace = 15;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

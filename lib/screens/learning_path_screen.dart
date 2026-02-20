import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'quiz_screen/premium_quiz_screen.dart';
import '../uri_links/links.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      final response = await http.get(Uri.parse('${baseUri}userapp/categories/${widget.categoryId}/lessons/'));
      if (response.statusCode == 200) {
        setState(() {
          _lessons = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
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
    );
  }

  Widget _buildHeader() {
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
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFF6DE00F), size: 32),
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
                style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '45% Complete',
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
            child: const LinearProgressIndicator(
              value: 0.45,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(Color(0xFF6DE00F)),
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

    // We reversed lessons to show intro at the bottom? 
    // Usually path starts from bottom.
    final reversedLessons = _lessons.reversed.toList();

    return Column(
      children: reversedLessons.asMap().entries.map((entry) {
        int index = entry.key;
        var lesson = entry.value;
        
        // Zig-zag offset logic
        double offset = 0;
        if (index % 4 == 1) offset = -50;
        if (index % 4 == 3) offset = 50;
        if (index % 4 == 2) offset = 0; // middle
        
        bool isActive = index == 2; // Hardcoded active for now
        bool isCompleted = index > 2;
        bool isLocked = index < 2;

        return Column(
          children: [
            _buildPathNode(
              label: lesson['name'] ?? 'Lesson',
              subLabel: 'Learn',
              isActive: isActive,
              isCompleted: isCompleted,
              isLocked: isLocked,
              offset: offset,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PremiumQuizScreen(levelId: 1, userId: widget.userId)),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPathNode({
    required String label,
    String? subLabel,
    bool isCompleted = false,
    bool isLocked = false,
    bool isActive = false,
    double offset = 0,
    VoidCallback? onTap,
  }) {
    return Transform.translate(
      offset: Offset(offset, 0),
      child: FadeIn(
        child: Column(
          children: [
            if (isActive)
              Bounce(
                infinite: true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Text(
                    'JUMP IN!',
                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            GestureDetector(
              onTap: isLocked ? null : (onTap ?? () {}),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isActive)
                    _PulseEffect(),
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
                      child: isLocked
                          ? const Icon(Icons.lock_rounded, color: Color(0xFF94A3B8), size: 32)
                          : isCompleted
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 48, weight: 1000)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      subLabel ?? '',
                                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
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
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.map_rounded, label: 'Path', isActive: true),
          _BottomNavItem(icon: Icons.videocam_rounded, label: 'Practice'),
          _BottomNavItem(icon: Icons.leaderboard_rounded, label: 'Leagues'),
          _BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
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

class _PulseEffectState extends State<_PulseEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _animation = Tween<double>(begin: 0.95, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
      builder: (context, child) => Container(
        width: 100 * _animation.value,
        height: 100 * _animation.value,
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(1 - (_controller.value)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _BottomNavItem({required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6DE00F).withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? const Color(0xFF6DE00F) : const Color(0xFF94A3B8), size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF6DE00F) : const Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
      ],
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

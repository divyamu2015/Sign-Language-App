import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../uri_links/links.dart';

import 'home_screen.dart';
import 'home_page/alphabetics_page.dart';
import 'home_page/numbers_pages.dart';
import 'category_page/category_view/category_view.dart';
import 'pratice_screen/practice_home.dart';
import 'quiz_screen/quiz_page.dart';
import 'profile_manage.dart';
import 'learning_path_screen.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
class _CatalogColors {
  static const Color primary = Color(0xFF6DE00F);
  static const Color backgroundLight = Color(0xFFF7F8F6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentPurple = Color(0xFFBA68C8);
  static const Color accentPink = Color(0xFFFF80AB);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
}

// ─── Module Data Model ───────────────────────────────────────────────────────
class _ModuleData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? progress; // null = no progress bar, show START button
  final bool isLocked;
  final VoidCallback? onTap;

  const _ModuleData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.progress,
    this.isLocked = false,
    this.onTap,
  });
}

// ─── Modules Catalog Screen ──────────────────────────────────────────────────
class ModulesCatalogScreen extends StatefulWidget {
  const ModulesCatalogScreen({super.key, this.userId = 0});
  final int userId;

  @override
  State<ModulesCatalogScreen> createState() => _ModulesCatalogScreenState();
}

class _ModulesCatalogScreenState extends State<ModulesCatalogScreen> {
  int _selectedNavIndex = 1; // Modules tab is active
  String _selectedFilter = 'All Modules';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    'All Modules',
    'Beginner',
    'Conversation',
    'Travel',
    'Advanced',
  ];

  List<_ModuleData> _allModules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoryView));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allModules = data.asMap().entries.map((entry) {
            int index = entry.key;
            var cat = entry.value;
            String title = cat['category_name'] ?? 'Module';
            return _ModuleData(
              title: title,
              subtitle: cat['description'] ?? 'Learn sign language',
              icon: _getIconForCategory(title),
              color: _getColorForCategory(index),
              progress: (index == 0) ? 0.85 : (index == 1) ? 0.40 : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LearningPathScreen(
                  title: '$title Path',
                  categoryId: cat['id'],
                  userId: widget.userId,
                )),
              ),
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconForCategory(String title) {
    String t = title.toLowerCase();
    if (t.contains('alphabet')) return Icons.abc_rounded;
    if (t.contains('number')) return Icons.looks_one_rounded;
    if (t.contains('greet')) return Icons.front_hand_rounded;
    if (t.contains('family')) return Icons.family_restroom_rounded;
    if (t.contains('emotion')) return Icons.sentiment_satisfied_alt_rounded;
    return Icons.sign_language_rounded;
  }

  Color _getColorForCategory(int index) {
    List<Color> colors = [
      _CatalogColors.primary,
      _CatalogColors.accentOrange,
      _CatalogColors.accentBlue,
      _CatalogColors.accentPurple,
      _CatalogColors.accentPink,
    ];
    return colors[index % colors.length];
  }

  List<_ModuleData> get _filteredModules {
    List<_ModuleData> modules = _allModules;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      modules = modules
          .where((m) =>
              m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return modules;
  }

  void _onNavTapped(int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(userId: widget.userId)),
        );
        break;
      case 1: // Modules (current)
        break;
      case 3: // Ranking
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnimatedGridScreen(userId: widget.userId)),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfManage(userId: widget.userId)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CatalogColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Header ────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader()),
                // ─── Search + Filters ──────────────────────────────
                SliverToBoxAdapter(child: _buildSearchAndFilters()),
                // ─── Module Grid ───────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: _isLoading 
                    ? const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(color: _CatalogColors.primary),
                        )),
                      )
                    : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final module = _filteredModules[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 + (index * 80)),
                          duration: const Duration(milliseconds: 500),
                          child: module.isLocked
                              ? _LockedModuleTile(module: module)
                              : _ModuleTile(module: module),
                        );
                      },
                      childCount: _filteredModules.length,
                    ),
                  ),
                ),
              ],
            ),
            // ─── Bottom Nav ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            // Total Mastery
            Column(
              children: [
                Text(
                  'TOTAL MASTERY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _CatalogColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: _CatalogColors.primary, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '2,450',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _CatalogColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Search button
            _CircleButton(
              icon: Icons.search_rounded,
              onTap: () {
                // Focus on the search field
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search + Filters ──────────────────────────────────────────────────────
  Widget _buildSearchAndFilters() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search modules...',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    color: _CatalogColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: _CatalogColors.textSecondary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? _CatalogColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _CatalogColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? _CatalogColors.textPrimary : _CatalogColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 16, left: 12, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _selectedNavIndex == 0,
              selectedColor: _CatalogColors.primary,
              onTap: () => _onNavTapped(0),
            ),
            _BottomNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Modules',
              isSelected: _selectedNavIndex == 1,
              selectedColor: _CatalogColors.primary,
              onTap: () => _onNavTapped(1),
            ),
            // Camera FAB
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI Camera coming soon!', style: GoogleFonts.spaceGrotesk()),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _CatalogColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _CatalogColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: _CatalogColors.backgroundLight, width: 4),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF182210), size: 28),
                ),
              ),
            ),
            _BottomNavItem(
              icon: Icons.leaderboard_rounded,
              label: 'Ranking',
              isSelected: _selectedNavIndex == 3,
              selectedColor: _CatalogColors.primary,
              onTap: () => _onNavTapped(3),
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: _selectedNavIndex == 4,
              selectedColor: _CatalogColors.primary,
              onTap: () => _onNavTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Module Tile (Active) ────────────────────────────────────────────────────
class _ModuleTile extends StatelessWidget {
  final _ModuleData module;
  const _ModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    final hasProgress = module.progress != null;
    return GestureDetector(
      onTap: module.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _CatalogColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: module.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(module.icon, color: module.color, size: 28),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              module.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _CatalogColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            // Subtitle
            Text(
              module.subtitle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: _CatalogColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress bar or START button
            if (hasProgress) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(module.progress! * 100).toInt()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: module.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: module.progress!,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(module.color),
                  minHeight: 4,
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: module.onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: module.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                    textStyle: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('START'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Locked Module Tile ──────────────────────────────────────────────────────
class _LockedModuleTile extends StatelessWidget {
  final _ModuleData module;
  const _LockedModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with lock badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(module.icon, color: Colors.grey.shade400, size: 28),
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.lock, size: 10, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              module.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              module.subtitle,
              style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.grey.shade400),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Placeholder bar
            Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: _CatalogColors.textPrimary.withOpacity(0.6), size: 20),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? selectedColor : _CatalogColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? selectedColor : _CatalogColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

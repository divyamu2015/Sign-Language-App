import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../home_screen.dart'; // To reuse ClayContainer and AppColors
import 'pratice_page.dart';

class PracCategoryScreen extends StatefulWidget {
  final String catName;
  final int userId;
  const PracCategoryScreen({super.key, required this.catName, required this.userId});

  @override
  State<PracCategoryScreen> createState() => _PracCategoryScreenState();
}

class _PracCategoryScreenState extends State<PracCategoryScreen> {
  List<dynamic> data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  Future<void> getCategory() async {
    final uri = Uri.parse(AppConfig.categoryView);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            data = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (AppConfig.useDemoMode) {
        if (mounted) {
          setState(() {
            data = [
              {"id": 1, "name": "Alphabets", "image": null, "color": Colors.blue.shade100, "icon": Icons.abc_rounded},
              {"id": 2, "name": "Numbers", "image": null, "color": Colors.green.shade100, "icon": Icons.pin_rounded},
              {"id": 3, "name": "Common Signs", "image": null, "color": Colors.orange.shade100, "icon": Icons.handshake_rounded},
              {"id": 4, "name": "Emotions", "image": null, "color": Colors.purple.shade100, "icon": Icons.sentiment_satisfied_rounded}
            ];
            _isLoading = false;
          });
        }
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
          'Practice',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: getCategory,
        color: AppColors.primary,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final cat = data[index];
                return FadeInLeft(
                  delay: Duration(milliseconds: 100 * index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _PracticeCategoryCard(
                      id: cat['id'],
                      name: cat['name'] ?? 'Category',
                      icon: cat['icon'] ?? Icons.sign_language_rounded,
                      color: cat['color'] ?? Colors.blue.shade50,
                      imageUrl: cat['image'],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _PracticeCategoryCard extends StatelessWidget {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const _PracticeCategoryCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PracticePage(catId: id, catName: name)),
        );
      },
      child: ClayContainer(
        height: 110,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClayContainer(
              width: 78,
              height: 78,
              borderRadius: 24,
              color: color,
              spread: 0,
              isInner: true,
              child: imageUrl != null 
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network("${AppConfig.baseUri}$imageUrl", fit: BoxFit.cover),
                )
                : Icon(icon, color: Color.lerp(color, Colors.black, 0.45), size: 34),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.lexend(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Practice signs and master them',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.clayShadow, size: 16),
          ],
        ),
      ),
    );
  }
}

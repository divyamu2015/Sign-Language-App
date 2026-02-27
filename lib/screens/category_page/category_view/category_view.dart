import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../lessons.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.catName,required this.userId});
  final String catName;
  final int userId;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> data = [];
  int? catId;
  String? catNam;
  @override
  void initState() {
    super.initState();
    catNam = widget.catName;
    getCategory();
  }

  Future<void> getCategory() async {
    final uri = Uri.parse(AppConfig.categoryView);
    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
        print('Category is============== $data');
      }
    } catch (e) {
      print('Error is ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(catNam!,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 87, 49, 94))),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                Color.fromARGB(255, 213, 148, 221),
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                Color.fromARGB(255, 213, 148, 221),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: data.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        child: CategoryCard(
                          id: data[index]['id'] ?? 0,
                          categoryName: data[index]['title'] ?? data[index]['name'] ?? 'Category',
                          imageWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "${AppConfig.baseUri}${data[index]['icon_url'] ?? data[index]['image'] ?? ''}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final Widget imageWidget;
  final int id; // Accepts a Widget instead of just a URL

  const CategoryCard({
    super.key,
    required this.id,
    required this.categoryName,
    required this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LessonPage(
              catId: id,
              catName: categoryName,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: categoryName,
        child: Card(
          elevation: 8,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 100,
            borderRadius: 15,
            blur: 15,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 249, 248, 250),
                const Color.fromARGB(255, 247, 245, 246).withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 214, 174, 233).withOpacity(0.3),
                const Color.fromARGB(255, 236, 192, 233).withOpacity(0.1)
              ],
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageWidget, // Uses the passed image widget
              ),
              title: Text(
                categoryName,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 114, 69, 122)),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: const Color.fromARGB(255, 114, 69, 122)),
            ),
          ),
        ),
      ),
    );
  }
}

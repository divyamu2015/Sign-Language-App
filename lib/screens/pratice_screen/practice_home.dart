import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import '../../../uri_links/links.dart';
import 'pratice_page.dart';
import 'package:signin_language_app/config/dev_config.dart';

class PracCategoryScreen extends StatefulWidget {
  final String catName;
  final int userId;
  const PracCategoryScreen(
      {super.key, required this.catName, required this.userId});

  @override
  State<PracCategoryScreen> createState() => _PracCategoryScreenState();
}

class _PracCategoryScreenState extends State<PracCategoryScreen> {
  List<dynamic> data = [];
  int? catId;
  int? userId;
  String? catName;
  @override
  void initState() {
    super.initState();
    catName = widget.catName;
    userId = widget.userId;
    getCategory();
  }

  Future<void> getCategory() async {
    final uri = Uri.parse(categoryView);
    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
        print('Category is============== $data');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error is ${e.toString()}');
      if (DevConfig.useDemoMode) {
        // Fallback data for working without backend
        setState(() {
          data = [
            {"id": 1, "name": "Basic Alphabets", "image": "assets/images/sign-language.png"},
            {"id": 2, "name": "Numbers 1-10", "image": "assets/images/sign-language.png"},
            {"id": 3, "name": "Simple Greetings", "image": "assets/images/sign-language.png"},
            {"id": 4, "name": "Family Signs", "image": "assets/images/sign-language.png"}
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color.fromARGB(255, 87, 49, 94), size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(catName!,
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
                          id: data[index]['id'],
                          categoryName: data[index]['name'],
                          imageWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: data[index]['image'] != null && data[index]['image'].startsWith('assets/')
                                ? Image.asset(
                                    data[index]['image'],
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    "$baseUri${data[index]['image']}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.asset('assets/images/sign-language.png', fit: BoxFit.cover),
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
            pageBuilder: (context, animation, secondaryAnimation) =>
                PracticePage(
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

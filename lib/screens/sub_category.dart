import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:signin_language_app/screens/home_page/numbers_pages.dart';
import '../authentication_screen/login_screen/login_view/login_page.dart';
import 'about_quiz.dart';
import 'category_page/category_view/category_view.dart';
import 'faq_screen.dart';
import 'home_page/alphabetics_page.dart';
// Import PracticePage
import 'pratice_screen/practice_home.dart';
import 'profile_manage.dart';
import 'quiz_screen/quiz_page.dart';

// Import QuizPage

// Define Category class properly
class Category {
  final String title;
  final IconData icon;
  final Widget screen; // Add screen navigation reference

  Category(this.title, this.icon, this.screen);
}

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key, this.userId = 0, this.userName = ''});
  final int userId;
  final String userName;

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  int? userId;
  String? userName;
  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    userName = widget.userName;
    print('Username ================$userName');
    }

  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    if (index == _selectedIndex && index == 0) return;
    if (index == _selectedIndex && index == 0) return;
    
    setState(() => _selectedIndex = index);
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

  void _initVideo() {} 

  void showAlertBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Do you want to Logout?',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) {
                        return LoginPage(
                            //userName: LoginPage,
                            //userId: userId,
                            );
                      },
                    ));
                  },
                  child: const Text('Yes'),
                )
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> subCategories = [
      Category(
          'Learning',
          Icons.school,
          CategoryScreen(
            catName: 'Learning',
            userId: userId!,
          )), // Navigate to CategoryScreen
      Category(
          'Practice',
          Icons.edit,
          PracCategoryScreen(
            catName: 'Practice',
            userId: userId!,
          )), // Navigate to PracticePage
      Category(
          'Quiz',
          Icons.quiz,
          AnimatedGridScreen(
            userId: userId!,
          )), // Navigate to QuizPage
    ];

    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 54, 220),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image(
                      image: AssetImage('assets/images/quiz.png'),
                      height: 100,
                      width: 100,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_2_outlined,
                  color: Colors.purpleAccent,
                ),
                title: const Text('Profile Management'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return UserProfManage(
                        userId: userId!,
                        //name: userName!,
                      );
                    },
                  ));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_2_outlined,
                  color: Colors.purpleAccent,
                ),
                title: const Text('FAQ'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return FAQScreen(
                          // userId: userId!,
                          // //name: userName!,
                          );
                    },
                  ));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.quiz_outlined,
                  color: Colors.purpleAccent,
                ),
                title: const Text(
                  'About Quiz',
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return AboutQuizPage(
                          // userId: userId!,
                          //name: userName!,
                          );
                    },
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  showAlertBox();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            'Sign Language',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 87, 49, 94),
            ),
          ),
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         Navigator.pushReplacement(context, MaterialPageRoute(
          //           builder: (context) {
          //             return LoginPage(
          //                 // userId: useri,
          //                 );
          //           },
          //         ));
          //       },
          //       icon: Icon(Icons.logout))
          // ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/back2.jpg"),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
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
            child: ListView.builder(
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                return FadeInLeft(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the corresponding screen
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return subCategories[index].screen;
                        },
                      ));
                    },
                    child: Card(
                      elevation: 8,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: 90,
                        borderRadius: 15,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 1,
                        linearGradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 249, 248, 250),
                            const Color.fromARGB(255, 247, 245, 246)
                                .withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 214, 174, 233)
                                .withOpacity(0.3),
                            const Color.fromARGB(255, 236, 192, 233)
                                .withOpacity(0.1)
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          leading: Icon(subCategories[index].icon,
                              color: const Color.fromARGB(255, 129, 71, 74),
                              size: 40),
                          title: Text(
                            subCategories[index].title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 114, 69, 122),
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: const Color.fromARGB(255, 114, 69, 122)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ),
        bottomNavigationBar: _buildBottomNav(),
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
              isActive: _selectedIndex == 0,
              onTap: () => _onNavTapped(0),
            ),
            _BottomNavItem(
              icon: Icons.fitness_center_rounded,
              label: 'Practice',
              isActive: _selectedIndex == 1,
              onTap: () => _onNavTapped(1),
            ),
            // Camera FAB
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI Camera coming soon!', style: GoogleFonts.lexend()),
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
              isActive: _selectedIndex == 4,
              onTap: () => _onNavTapped(4),
            ),
          ],
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

//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signin_language_app/authentication_screen/login_screen/bloc/login_bloc.dart';
import '../../../screens/home_screen.dart';
import '../../signup_screen/signup_view/signup_view.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import '../screens/user_models/home_screen.dart';
//import 'package:http/http.dart' as http;
//import '../url_collections/uri_collection.dart';
//import 'signin/page/signin_page_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(
      {super.key, this.userName = '', this.userId = 0, this.userPass = ''});

  final String? userName;
  final int? userId;
  final String? userPass;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  String? data;
  int? userId;
  String? role;
  String? userName;
  String? userPass;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userName = widget.userName; // userid = widget.userId;
    userPass = widget.userPass;
  }

   Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    context.read<LoginBloc>().add(LoginEvent.userlogin(
          userId: '0',
          email: emailController.text.trim(),
          paswd: passController.text.trim(),
        ));
  }

  Future<void> storeUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    print("User ID stored in SharedPreferences: $userId");
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print("Retrieved User ID: $userId");
    return userId;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          state.when(
            initial: () {},
            loading: () => setState(() => isLoading = true),
            success: (response) async {
              if (response.userId != null) {
                await storeUserId(int.parse(response.userId!));
              }
              userId = await getUserId();
              setState(() {
                isLoading = false;
                showSuccess('User logged in successfully');
                if (userId != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: userId!),
                    ),
                  );
                } else {
                  showError("User ID not found");
                }
              });
            },
            error: (error) {
              setState(() {
                isLoading = false;
                showError('Incorrect Email or Password');
              });
            },
          );
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Top Artwork ───────────────────────────────────────────────
              Container(
                height: height * 0.45,
                width: width,
                decoration: BoxDecoration(
                  color: const Color(0xFF36E27B).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back Button
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF0F172A), size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    // Floating Shapes
                    Positioned(
                      top: 40,
                      left: -20,
                      child: FadeInLeft(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF36E27B).withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      right: -30,
                      child: FadeInRight(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFF36E27B).withOpacity(0.05),
                        ),
                      ),
                    ),
                    
                    // Main Avatar
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        ZoomIn(
                          duration: const Duration(milliseconds: 800),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/sign-language.png'),
                                    fit: BoxFit.contain,
                                  ),
                                  border: Border.all(color: Colors.white, width: 8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: -15,
                                child: SlideInUp(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.front_hand_rounded, color: Color(0xFF36E27B), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'WELCOME!',
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Form Section ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ready to continue your signing journey?',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter Email';
                              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                                return 'Enter a valid Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: passController,
                            obscureText: !isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter Password';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              color: Color(0xFF36E27B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF36E27B),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 10,
                            shadowColor: const Color(0xFF36E27B).withOpacity(0.4),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or sign in with',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(icon: Icons.g_mobiledata_rounded, color: Colors.red.shade400),
                          const SizedBox(width: 20),
                          _SocialButton(icon: Icons.apple_rounded, color: Colors.black),
                        ],
                      ),

                      const SizedBox(height: 40),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(
                                  userName: userName,
                                  userId: userId,
                                  userPass: userPass,
                                ),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Lexend', color: Colors.grey.shade500, fontSize: 15),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                const TextSpan(
                                  text: 'Create an Account',
                                  style: TextStyle(
                                    color: Color(0xFF36E27B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signin_language_app/authentication_screen/login_screen/bloc/login_bloc.dart';
import '../../../screens/sub_category.dart';
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
      backgroundColor: Colors.purple,
     body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          state.when(
            initial: () {},
            loading: () {
              setState(() {
                isLoading = true;
              });
            },
            success: (response) async {
              if (response.userId != null) {
                await storeUserId(int.parse(response.userId!));
              }

              userId = await getUserId(); // Retrieve and assign userId

              setState(() {
                isLoading = false;
                showSuccess('User logged in successfully');
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SubCategoryPage(userId: userId!);
                      },
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
                showError('Incorrect Username and Password');
              });
            },
          );
          // TODO: implement listener
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                //Color.fromARGB(255, 98, 159, 238),
                Color.fromARGB(255, 213, 148, 221),
                Color.fromARGB(255, 231, 173, 243),
                Color.fromARGB(255, 245, 176, 239),
                //Color.fromARGB(255, 98, 159, 238),
                Color.fromARGB(255, 213, 148, 221),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 250, left: 18, right: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 0.2 * height,
                      ),
                      Container(
                        // height: 0.1 * height,
                        // width: 0.7 * width,
                        // decoration: BoxDecoration(
                        //   gradient: LinearGradient(
                        //     colors: [
                        //       Color.fromARGB(255, 231, 173, 243),
                        //       Color.fromARGB(255, 245, 176, 239),
                        //       //Color.fromARGB(255, 98, 159, 238),
                        //       Color.fromARGB(255, 213, 148, 221),
                        //     ],
                        //     begin: Alignment.topLeft,
                        //     end: Alignment.bottomRight,
                        //   ),
                        // ),
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                child: Image.asset(
                                    'assets/images/sign-language.png'),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "SIGN LANGUAGE",
                                style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              )
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true))
                                  .fadeOut(curve: Curves.easeInOut),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 0.1 * height,
                      ),
                      //SIGN LANGUAGE
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          bool isEmail = RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value);

                          if (!isEmail) {
                            return 'Enter a valid Email';
                          }
                          return null;
                        },
                        controller: emailController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(
                            Icons.person_outline_outlined,
                            color: Color.fromARGB(255, 105, 23, 116),
                          ),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }

                          return null;
                        },
                        controller: passController,
                        obscureText:
                            !isPasswordVisible, // Toggle password visibility
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color.fromARGB(255, 105, 23, 116),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fixedSize: Size.fromWidth(width),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 105, 23, 116),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 175, 125, 184),
                        ),
                        onPressed: isLoading ? null : login,
                        // login;
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (context) {
                        //     return CategoryScreen();

                        // ));
                        //  },
                        // login,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage(
                                    userName: userName,
                                    userId: userId,
                                    userPass: userPass)),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Don\'t have an account? '),
                              TextSpan(
                                text: 'SignUp',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 105, 23, 116),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

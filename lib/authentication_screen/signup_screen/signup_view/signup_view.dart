import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signin_language_app/authentication_screen/login_screen/login_view/login_page.dart';

import '../bloc/signup_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.userName,
    required this.userId,
    required this.userPass,
  });
  final String? userName;
  final int? userId;
  final String? userPass;
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController name = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isPasswordVisible = false;
  String? data;
  int? userid;
  String? role;
  String? userName;
  String? userPass;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    userid = widget.userId;
    userPass = widget.userPass;
    print("For Wate Management Display=====$userName");
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

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });
    context.read<SignupBloc>().add(SignupEvent.useRegistration(
        id: userid.toString(),
        username: name.text,
        email: emailController.text.trim(),
        phone: phonenum.text.trim(),
        password: passController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.purple,
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          // TODO: implement listener
          state.when(
            initial: () {},
            loading: () {
              setState(() {
                isLoading = true;
              });
            },
            error: (error) {
              setState(() {
                isLoading = false;
                showError(error);
              });
            },
            success: (response) {
              setState(() {
                isLoading = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Registration successful!'),
                      backgroundColor: Colors.green),
                );
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return LoginPage(
                        userName: userName, userId: userid, userPass: userPass);
                  },
                ));
              });
            },
          );
        },
        child: SafeArea(
          child: Container(
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
            // Wrap the content in SingleChildScrollView
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 250, left: 18, right: 18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 0.2 * height),
                    Center(
                      child: Text(
                        "SIGN LANGUAGE",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 93, 29, 104),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .fadeOut(curve: Curves.easeInOut),
                    ),
                    SizedBox(height: 0.1 * height),
                    // Name TextFormField

                    TextFormField(
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Name';
                        }
                        return null;
                      },
                      controller: name,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.person_outline_outlined,
                          color: Color.fromARGB(255, 105, 23, 116),
                        ),
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email TextFormField
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Phone';
                        }
                        bool isPhone = RegExp(r"^[0-9]{10}$").hasMatch(value);
                        if (!isPhone) {
                          return 'Enter 10-digit number';
                        }
                        return null;
                      },
                      controller: phonenum,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.person_outline_outlined,
                          color: Color.fromARGB(255, 105, 23, 116),
                        ),
                        hintText: 'Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password TextFormField
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // LOGIN Button
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
                      onPressed: isLoading ? null : signUp,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SIGN Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

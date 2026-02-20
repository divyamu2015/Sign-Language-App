import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () => setState(() => isLoading = true),
            error: (error) {
              setState(() {
                isLoading = false;
                showError(error);
              });
            },
            success: (response) {
              setState(() {
                isLoading = false;
                showSuccess('Registration successful!');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      userName: userName,
                      userId: userid,
                      userPass: userPass,
                    ),
                  ),
                );
              });
            },
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create Your\nLearning Account",
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Join our community and start your sign language journey today!",
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Name Field
                        _buildInputField(
                          controller: name,
                          hint: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          delay: 100,
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        _buildInputField(
                          controller: emailController,
                          hint: 'Email Address',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          delay: 200,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Email';
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                              return 'Enter a valid Email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone Field
                        _buildInputField(
                          controller: phonenum,
                          hint: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          delay: 300,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Phone';
                            if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) return 'Enter 10-digit number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildInputField(
                          controller: passController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: isPasswordVisible,
                          onTogglePassword: () => setState(() => isPasswordVisible = !isPasswordVisible),
                          delay: 400,
                        ),

                        const SizedBox(height: 24),
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: true,
                                  onChanged: (v) {},
                                  activeColor: const Color(0xFF36E27B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontFamily: 'Lexend', color: Colors.grey.shade500, fontSize: 13),
                                    children: const [
                                      TextSpan(text: 'I agree to the '),
                                      TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF36E27B), fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' and '),
                                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF36E27B), fontWeight: FontWeight.bold)),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STEP 1 OF 3',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF36E27B),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Almost there!',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.33,
                    backgroundColor: const Color(0xFF36E27B).withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF36E27B)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    required int delay,
    String? Function(String?)? validator,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
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
          controller: controller,
          obscureText: isPassword && !(isPasswordVisible ?? false),
          keyboardType: keyboardType,
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) return 'Please enter $hint';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade400),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                (isPasswordVisible ?? false) ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: Colors.grey.shade400,
              ),
              onPressed: onTogglePassword,
            ) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: isLoading ? null : signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36E27B),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontFamily: 'Lexend', color: Colors.grey.shade500, fontSize: 14),
                children: const [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Log In',
                    style: TextStyle(color: Color(0xFF36E27B), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

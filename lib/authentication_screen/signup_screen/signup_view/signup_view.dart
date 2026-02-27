import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signin_language_app/authentication_screen/login_screen/login_view/login_page.dart'; // To reuse AuthColors and ClayContainer
import '../bloc/signup_bloc.dart';
import '../../../screens/home_screen.dart'; // For AppColors

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<SignupBloc>().add(SignupEvent.useRegistration(
      id: widget.userId.toString(),
      username: _nameController.text,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.clayBg,
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () => setState(() => _isLoading = true),
            error: (error) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error), backgroundColor: Colors.red),
              );
            },
            success: (response) {
              setState(() {
                _isLoading = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              });
            },
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTopBar(),
                const SizedBox(height: 30),
                _buildMainCard(),
                const SizedBox(height: 32),
                _buildSignInLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ClayIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
        Text(
          'Join Signly',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 48), // Spacer
      ],
    );
  }

  Widget _buildMainCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: ClayContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 48,
        spread: 12,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStepper(),
              const SizedBox(height: 32),
              Text(
                'Create Account',
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your journey to master ASL',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildInputField(
                label: 'FULL NAME',
                controller: _nameController,
                hint: 'John Doe',
                icon: Icons.person_rounded,
                iconColor: AuthColors.clayBlue,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                label: 'EMAIL',
                controller: _emailController,
                hint: 'your@email.com',
                icon: Icons.alternate_email_rounded,
                iconColor: AuthColors.clayPink,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                label: 'PHONE',
                controller: _phoneController,
                hint: '1234567890',
                icon: Icons.phone_rounded,
                iconColor: AuthColors.primary,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                label: 'PASSWORD',
                controller: _passController,
                hint: '••••••••',
                icon: Icons.lock_rounded,
                iconColor: AuthColors.clayBlue,
                isPassword: true,
              ),
              
              const SizedBox(height: 40),
              
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 1 OF 1',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AuthColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Fast & Easy',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.clayShadow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AuthColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary.withOpacity(0.6),
              letterSpacing: 2,
            ),
          ),
        ),
        ClayContainer(
          height: 60,
          borderRadius: 20,
          spread: 0,
          isInner: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isPassword && !_isPasswordVisible,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.lexend(color: AppColors.clayShadow.withOpacity(0.5)),
                    border: InputBorder.none,
                    suffixIcon: isPassword ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: AppColors.clayShadow.withOpacity(0.5),
                        size: 18,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _signUp,
      child: ClayContainer(
        height: 72,
        width: double.infinity,
        borderRadius: 28,
        color: AuthColors.primary,
        child: Center(
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GET STARTED',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lexend(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          children: const [
            TextSpan(text: 'Already a member? '),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(color: AuthColors.primary, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ClayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        width: 48,
        height: 48,
        borderRadius: 16,
        child: Icon(icon, color: AppColors.textPrimary, size: 24),
      ),
    );
  }
}

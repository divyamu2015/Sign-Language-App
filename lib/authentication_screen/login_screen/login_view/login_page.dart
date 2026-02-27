import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signin_language_app/authentication_screen/login_screen/bloc/login_bloc.dart';
import '../../../screens/home_screen.dart'; // To reuse AppColors and ClayContainer
import '../../signup_screen/signup_view/signup_view.dart';

// Locally define the specific Auth Clay colors to match the HTML
class AuthColors {
  static const Color primary = Color(0xFFFF7E47);
  static const Color clayBg = Color(0xFFF0F4FF);
  static const Color clayBlue = Color(0xFF4D77FF);
  static const Color clayPink = Color(0xFFFF6B9D);
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key, 
    this.userName = '', 
    this.userId = 0, 
    this.userPass = ''
  });

  final String? userName;
  final int? userId;
  final String? userPass;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<LoginBloc>().add(LoginEvent.userlogin(
      userId: '0',
      email: _emailController.text.trim(),
      paswd: _passController.text.trim(),
    ));
  }

  Future<void> _storeUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  void _devLogin() async {
    // Hidden dev hook to bypass login
    await _storeUserId(117);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Developer Access Granted'),
          backgroundColor: AuthColors.clayBlue,
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(
            userId: 117,
            userName: 'Developer',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.clayBg,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () => setState(() => _isLoading = true),
            success: (response) async {
              setState(() => _isLoading = false);
              
              String? userIdStr = response.userId;
              // Fallback: Check if response.user.id exists directly if getter fails
              userIdStr ??= response.user?.id?.toString();

              if (userIdStr != null) {
                int id = int.parse(userIdStr);
                await _storeUserId(id);
                
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        userId: id,
                        userName: response.user?.name ?? '',
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login successful but user data missing')),
                );
              }
            },
            error: (error) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incorrect Email or Password'), backgroundColor: Colors.red),
              );
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
                _buildCreateAccountLink(),
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
          'Signly',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 48), // Spacer for balance
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
              GestureDetector(
                onTap: _devLogin,
                child: _buildLogo(),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome!',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your sign language journey today',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Email Field
              _buildInputField(
                label: 'EMAIL',
                controller: _emailController,
                hint: 'your@email.com',
                icon: Icons.alternate_email_rounded,
                iconColor: AuthColors.clayBlue,
              ),
              const SizedBox(height: 24),

              // Password Field
              _buildInputField(
                label: 'PASSWORD',
                controller: _passController,
                hint: '••••••••',
                icon: Icons.lock_rounded,
                iconColor: AuthColors.clayPink,
                isPassword: true,
              ),
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Reset password?',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AuthColors.clayBlue,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sign In Button
              _buildSignInButton(),
              
              const SizedBox(height: 40),
              _buildQuickAccess(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ZoomIn(
      child: ClayContainer(
        width: 100,
        height: 100,
        borderRadius: 32,
        color: AuthColors.primary,
        spread: 4,
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.sign_language_rounded, color: Colors.white, size: 48),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isPassword = false,
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
          height: 64,
          borderRadius: 24,
          spread: 0,
          isInner: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: isPassword && !_isPasswordVisible,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.lexend(color: AppColors.clayShadow.withOpacity(0.5)),
                    border: InputBorder.none,
                    suffixIcon: isPassword ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: AppColors.clayShadow.withOpacity(0.5),
                        size: 20,
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

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
      child: ClayContainer(
        height: 72,
        width: double.infinity,
        borderRadius: 28,
        color: AuthColors.primary,
        child: Center(
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'SIGN IN',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.clayShadow.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'QUICK ACCESS',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.clayShadow.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(asset: 'google'),
            const SizedBox(width: 24),
            _SocialButton(asset: 'apple'),
            const SizedBox(width: 24),
            _SocialButton(asset: 'meta'),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateAccountLink() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignUpPage(userName: '', userId: 0, userPass: '')),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lexend(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          children: const [
            TextSpan(text: 'New here? '),
            TextSpan(
              text: 'Create Account',
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

class _SocialButton extends StatelessWidget {
  final String asset;
  const _SocialButton({required this.asset});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      width: 64,
      height: 64,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Icon(
        asset == 'google' ? Icons.g_mobiledata_rounded : (asset == 'apple' ? Icons.apple_rounded : Icons.facebook_rounded),
        size: 32,
        color: AppColors.textPrimary,
      ),
    );
  }
}

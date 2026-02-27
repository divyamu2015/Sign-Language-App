import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import 'home_screen.dart'; // To reuse ClayContainer and AppColors
import '../config/app_config.dart';

class UserProfManage extends StatefulWidget {
  const UserProfManage({super.key, this.userId = 0});
  final int userId;

  @override
  State<UserProfManage> createState() => _UserProfManageState();
}

class _UserProfManageState extends State<UserProfManage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  bool isLoading = true;

  String name = "", email = "", phone = "";
  final TextEditingController addressController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final uri = Uri.parse(AppConfig.viewProfileUri(widget.userId));
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            name = data['username'] ?? '';
            email = data['email'] ?? '';
            phone = data['phone'] ?? '';
            addressController.text = data['address'] ?? '';
            placeController.text = data['place'] ?? '';
            isLoading = false;
          });
        }
      } else {
        throw ('Failed to fetch user profile');
      }
    } catch (e) {
      if (AppConfig.useDemoMode) {
        if (mounted) {
          setState(() {
            name = AppConfig.demoUserName;
            email = "demo@example.com";
            phone = "+1 234 567 890";
            addressController.text = "123 Sign Street";
            placeController.text = "Hand City";
            isLoading = false;
          });
        }
      }
    }
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final uri = Uri.parse(AppConfig.updateProfileUri(widget.userId));

      final updatedData = {
        "username": name,
        "email": email,
        "phone": phone,
        "address": addressController.text,
        "place": placeController.text,
      };

      try {
        final response = await http.patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedData),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              isEditing = false;
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully!")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
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
          'Profile',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: isEditing ? saveProfile : toggleEdit,
                child: ClayContainer(
                  width: 44,
                  height: 44,
                  borderRadius: 14,
                  color: isEditing ? AppColors.primary : AppColors.surface,
                  spread: 2,
                  child: Icon(
                    isEditing ? Icons.check_rounded : Icons.edit_rounded, 
                    color: isEditing ? Colors.white : AppColors.textPrimary, 
                    size: 20
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              FadeInDown(
                child: Center(
                  child: Stack(
                    children: [
                      ClayContainer(
                        width: 120,
                        height: 120,
                        borderRadius: 60,
                        spread: 4,
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 60, color: AppColors.clayShadow),
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ClayContainer(
                            width: 36,
                            height: 36,
                            borderRadius: 18,
                            color: AppColors.primary,
                            child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileField('Full Name', name, Icons.person_outline_rounded, false),
                      const SizedBox(height: 20),
                      _buildProfileField('Email Address', email, Icons.email_outlined, false),
                      const SizedBox(height: 20),
                      _buildProfileField('Phone Number', phone, Icons.phone_android_rounded, false),
                      const SizedBox(height: 20),
                      _buildEditableField('Home Address', addressController, Icons.home_work_outlined, true),
                      const SizedBox(height: 20),
                      _buildEditableField('Place', placeController, Icons.location_on_outlined, false),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ),
        ClayContainer(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          borderRadius: 16,
          isInner: true,
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 16),
              Text(value, style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textPrimary.withOpacity(0.6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, bool isMultiLine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ),
        ClayContainer(
          height: isMultiLine ? 100 : 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          borderRadius: 16,
          isInner: isEditing,
          child: Row(
            crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: isMultiLine ? 18 : 0),
                child: Icon(icon, color: isEditing ? AppColors.primary : AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEditing,
                  maxLines: isMultiLine ? 3 : 1,
                  style: GoogleFonts.lexend(fontSize: 16, color: AppColors.textPrimary),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

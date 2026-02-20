import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';

class UserProfManage extends StatefulWidget {
  const UserProfManage({super.key, this.userId = 0});
  final int userId;

  @override
  State<UserProfManage> createState() => _UserProfManageState();
}

class _UserProfManageState extends State<UserProfManage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  String name = "", email = "", phone = "";
  final TextEditingController addressController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final uri = Uri.parse(
        'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp/view_profile/${widget.userId}/');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['username'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          placeController.text = data['place'] ?? '';
        });
      } else {
        throw ('Failed to fetch user profile');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse(
          'https://5h44kl7q-8001.inc1.devtunnels.ms/userapp/profile/update/${widget.userId}/');

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
          print("Profile updated");
          setState(() => isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        } else {
          throw ('Failed to update profile');
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // light background
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return HomeScreen(
                      userName: name,
                    );
                  },
                ));
              },
              icon: Icon(Icons.arrow_back)),
          backgroundColor: const Color.fromARGB(255, 208, 150, 231),
          title: const Text("Profile Management"),
          actions: [
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: isEditing ? saveProfile : toggleEdit,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: _inputDecoration(name),
                    enabled: false,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: email,
                    decoration: _inputDecoration(email),
                    enabled: false,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: phone,
                    decoration: _inputDecoration(phone),
                    enabled: false,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: _inputDecoration("Address"),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Address cannot be empty";
                      }
                      return null;
                    },
                    enabled: isEditing,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: placeController,
                    decoration: _inputDecoration("Place"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Place cannot be empty";
                      }
                      return null;
                    },
                    enabled: isEditing,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  if (isEditing)
                    ElevatedButton.icon(
                      onPressed: saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

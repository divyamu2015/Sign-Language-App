import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';
import '../signup_model/signup_model.dart';
import 'package:http/http.dart' as http;

Future<UserRegModel> useRegistration({
  required String id, // Keeping for compatibility, not used in body
  required String username,
  required String email,
  required String phone,
  required String password,
}) async {
  try {
    final uri = Uri.parse(AppConfig.userRegistration);
    final Map<String, dynamic> body = {
      'name': username,
      'email': email,
      'password': password,
      'phone': phone
    };

    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }, 
        body: jsonEncode(body));
    
    final Map<String, dynamic> decoded = jsonDecode(res.body);
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      final response = UserRegModel.fromJson(decoded);
      
      // Store token if returned immediately upon registration
      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.token!);
        if (response.user?.id != null) {
          await prefs.setInt('user_id', response.user!.id!);
        }
      }
      
      return response;
    } else {
      final errorMsg = decoded['error'] ?? 'Registration failed';
      throw Exception(errorMsg);
    }
  } on SocketException {
    throw Exception('No internet connection');
  } on HttpException {
    throw Exception('Server error');
  } on FormatException {
    throw Exception('Invalid response format');
  } catch (e) {
    throw Exception(e.toString());
  }
}

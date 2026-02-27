import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:signin_language_app/authentication_screen/login_screen/login_model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';

Future<UserLoginModel> userlogin({
  required String userId, // Keeping for compatibility, but not used in body
  required String email,
  required String paswd,
}) async {
  try {
    final uri = Uri.parse(AppConfig.userLoginuri);
    final Map<String, dynamic> body = {
      'email': email,
      'password': paswd
    };
    
    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }, 
        body: jsonEncode(body));
    
    final Map<String, dynamic> decoded = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final response = UserLoginModel.fromJson(decoded);
      
      // Store token securely if present
      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.token!);
        if (response.user?.id != null) {
          await prefs.setInt('user_id', response.user!.id!);
        }
        if (response.user?.name != null) {
          await prefs.setString('user_name', response.user!.name!);
        }
      }
      
      return response;
    } else {
      final errorMsg = decoded['error'] ?? 'Failed to login';
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

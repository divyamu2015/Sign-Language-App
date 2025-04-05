import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:signin_language_app/authentication_screen/login_screen/login_model/login_model.dart';

import '../../../uri_links/links.dart';

Future<UserLoginModel> userlogin({
  required String userId,
  required String email,
  required String paswd,
}) async {
  try {
    final uri = Uri.parse(userLoginuri);
    final Map<String, dynamic> body = {
      'user_id': userId,
      'email': email,
      'password': paswd
    };
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode(body));
    final Map<String,dynamic> decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
       final response = UserLoginModel.fromJson(decoded);
    return response;
    }
   
 else {
      throw Exception('Failed to load response');
    }
  } on SocketException {
    throw Exception('Server error');
  } on HttpException {
    throw Exception('Something went wrong');
  } on FormatException {
    throw Exception('Bad request');
  } catch (e) {
    throw Exception(e.toString());
  }
}

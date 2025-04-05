import 'dart:convert';
import 'dart:io';

import '../../../uri_links/links.dart';
import '../signup_model/signup_model.dart';
import 'package:http/http.dart' as http;

Future<UserRegModel> useRegistration({
  required String id,
  required String username,
  required String email,
  required String phone,
  required String password,
}) async {
  try {
    final uri = Uri.parse(userRegistration);
    final Map<String, dynamic> body = {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password
    };

    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    final Map<String, dynamic> decoded = jsonDecode(res.body);
    print(decoded);
    if (res.statusCode == 200) {
      print(res);
      print(res.body);
      print(res.statusCode);
      final response = UserRegModel.fromJson(decoded);
      print(response);
      return response;
    } else {
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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';
import '../config/app_config.dart';

class QuizService {
  Future<List<Quiz>> fetchAllQuizzes({String? difficulty}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    String url = AppConfig.quizzesUri;
    if (difficulty != null) {
      url += '?difficulty=$difficulty';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Quiz.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  Future<Quiz> fetchQuizDetail(int quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse(AppConfig.getQuizDetailUri(quizId)),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load quiz detail');
    }
  }

  Future<QuizSubmitResponse> submitQuizAnswers(int quizId, int userId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final body = json.encode({
      'user_id': userId,
      'score': score,
    });
    debugPrint('📤 Submitting quiz: POST ${AppConfig.submitQuizUri(quizId)} body=$body');

    final response = await http.post(
      Uri.parse(AppConfig.submitQuizUri(quizId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body,
    );

    debugPrint('📥 Submit response: ${response.statusCode} ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return QuizSubmitResponse.fromJson(json.decode(response.body));
      } catch (e) {
        debugPrint('⚠️ Could not parse submit response: $e — returning defaults');
        return QuizSubmitResponse(status: 'ok', attemptId: 0, xpGained: 0, currentXp: 0);
      }
    } else {
      throw Exception('Failed to submit quiz answers (${response.statusCode}): ${response.body}');
    }
  }
}

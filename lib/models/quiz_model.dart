class Quiz {
  final int id;
  final String title;
  final String? description;
  final String? createdAt;
  final String? difficulty;
  final List<Question>? questions;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
    this.difficulty,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
      difficulty: json['difficulty'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((i) => Question.fromJson(i))
              .toList()
          : null,
    );
  }
}

class Question {
  final int id;
  final String text;
  final String? image;
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    this.image,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      image: json['image'],
      options: (json['options'] as List)
          .map((i) => Option.fromJson(i))
          .toList(),
    );
  }
}

class Option {
  final int id;
  final String text;
  final bool isCorrect;

  Option({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class QuizSubmitResponse {
  final String status;
  final int attemptId;
  final int xpGained;
  final int currentXp;

  QuizSubmitResponse({
    required this.status,
    required this.attemptId,
    required this.xpGained,
    required this.currentXp,
  });

  factory QuizSubmitResponse.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResponse(
      status: json['status'],
      attemptId: json['attempt_id'],
      xpGained: json['xp_gained'],
      currentXp: json['current_xp'],
    );
  }
}

// To parse this JSON data, do
//
//     final userLoginModel = userLoginModelFromJson(jsonString);

import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) => UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
    String? status;
    String? message;
    String? userId;

    UserLoginModel({
        this.status,
        this.message,
        this.userId,
    });

    factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
        status: json["status"],
        message: json["message"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user_id": userId,
    };
}

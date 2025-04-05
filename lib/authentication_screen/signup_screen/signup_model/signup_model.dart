// To parse this JSON data, do
//
//     final userRegModel = userRegModelFromJson(jsonString);

import 'dart:convert';

UserRegModel userRegModelFromJson(String str) => UserRegModel.fromJson(json.decode(str));

String userRegModelToJson(UserRegModel data) => json.encode(data.toJson());

class UserRegModel {
    String status;
    String message;
    Data data;

    UserRegModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory UserRegModel.fromJson(Map<String, dynamic> json) => UserRegModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    int id;
    String username;
    String email;
    String phone;
    String password;

    Data({
        required this.id,
        required this.username,
        required this.email,
        required this.phone,
        required this.password,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
    };
}

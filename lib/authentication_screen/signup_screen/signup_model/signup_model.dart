import 'dart:convert';

UserRegModel userRegModelFromJson(String str) => UserRegModel.fromJson(json.decode(str));

String userRegModelToJson(UserRegModel data) => json.encode(data.toJson());

class UserRegModel {
    String? token;
    RegUser? user;
    String? error;

    UserRegModel({
        this.token,
        this.user,
        this.error,
    });

    factory UserRegModel.fromJson(Map<String, dynamic> json) => UserRegModel(
        token: json["token"],
        user: json["user"] != null ? RegUser.fromJson(json["user"]) : null,
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
        "error": error,
    };
}

class RegUser {
    int? id;
    String? name;
    String? email;

    RegUser({
        this.id,
        this.name,
        this.email,
    });

    factory RegUser.fromJson(Map<String, dynamic> json) => RegUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
    };
}

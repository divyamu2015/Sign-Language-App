import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) => UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
    String? token;
    AuthUser? user;
    String? error;

    UserLoginModel({
        this.token,
        this.user,
        this.error,
    });

    factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
        token: json["token"],
        user: json["user"] != null ? AuthUser.fromJson(json["user"]) : null,
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
        "error": error,
    };

    // Compatibility getter for old code
    String? get userId => user?.id?.toString();
}

class AuthUser {
    int? id;
    String? name;
    String? email;
    String? phone;
    String? avatarUrl;

    AuthUser({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.avatarUrl,
    });

    factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        avatarUrl: json["avatar_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "avatar_url": avatarUrl,
    };
}

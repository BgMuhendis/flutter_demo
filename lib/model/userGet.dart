import 'dart:convert';

User userFromMap(String str) => User.fromMap(json.decode(str));

String userToMap(User data) => json.encode(data.toMap());

class User {
    User({
        this.count,
        this.data,
    });

    int count;
    List<UserInfo> data;

    factory User.fromMap(Map<String, dynamic> json) => User(
        count: json["count"],
        data: List<UserInfo>.from(json["data"].map((x) => UserInfo.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "count": count,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
    };
}

class UserInfo {
    UserInfo({
        this.id,
        this.username,
        this.password,
        this.city,
        this.birthday,
        this.fullname,
        this.isActive,
    });

    int id;
    String username;
    String password;
    String city;
    DateTime birthday;
    String fullname;
    int isActive;

    factory UserInfo.fromMap(Map<String, dynamic> json) => UserInfo(
        id: json["id"],
        username: json["username"],
        password: json["password"],
        city: json["city"],
        birthday: DateTime.parse(json["birthday"]),
        fullname: json["fullname"],
        isActive: json["isActive"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "password": password,
        "city": city,
        "birthday": birthday.toIso8601String(),
        "fullname": fullname,
        "isActive": isActive,
    };
}

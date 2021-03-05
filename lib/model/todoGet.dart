import 'dart:convert';

Todo TodoFromMap(String str) => Todo.fromMap(json.decode(str));

String TodoToMap(Todo data) => json.encode(data.toMap());

class Todo {
    Todo({
        this.count,
        this.body,
    });

    int count;
    List<Body> body;

    factory Todo.fromMap(Map<String, dynamic> json) => Todo(
        count: json["count"],
        body: List<Body>.from(json["body"].map((x) => Body.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "count": count,
        "body": List<dynamic>.from(body.map((x) => x.toMap())),
    };
}

class Body {
    Body({
        this.id,
        this.name,
        this.date,
        this.TodoId,
        this.isActive,
    });

    int id;
    String name;
    DateTime date;
    int TodoId;
    int isActive;

    factory Body.fromMap(Map<String, dynamic> json) => Body(
        id: json["id"],
        name: json["name"],
        date: DateTime.parse(json["date"]),
        TodoId: json["TodoId"],
        isActive: json["isActive"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "date": date.toIso8601String(),
        "TodoId": TodoId,
        "isActive": isActive,
    };
}

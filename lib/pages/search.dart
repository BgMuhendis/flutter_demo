import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_demo/model/todoGet.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataSearch extends SearchDelegate<String> {
  SharedPreferences sharedPreferences;
  List names;
  Todo _todo;
  String request_url = "https://aodapi.eralpsoftware.net/";

  final recentCities = ["ghgfh", "hgjhgjh"];
  Future<Todo> getTodoControl() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final get_response = await http.get(
      request_url + "todo",
      headers: {
        "token": sharedPreferences.getString("/token/"),
      },
    );
    if (get_response.statusCode == 200) {
      var decodedJson = json.decode(get_response.body);
      _todo = Todo.fromMap(decodedJson);
      names = _todo.body.map((e) => e.name).toList();
      return _todo;
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Visibility(
        visible: query.isEmpty ? false : true,
        child: IconButton(
          icon: Icon(Icons.clear),
          color: Colors.black,
          onPressed: () {
            query = "";
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    Future<Todo> call = getTodoControl();
    List suggessionList;
    final queryStatu = query.isEmpty ? true : false;
    suggessionList = query.isEmpty
        ? recentCities
        : names
            .where((element) =>
                element.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return queryStatu
        ? Text("")
        : ListView.builder(
            itemCount: suggessionList.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                        text: suggessionList[index].substring(0, query.length),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: suggessionList[index].substring(query.length),
                            style: TextStyle(color: Colors.black54),
                          )
                        ]),
                  ),
                ),
              );
            },
          );
  }
}

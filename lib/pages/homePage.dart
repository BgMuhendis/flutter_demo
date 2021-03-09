import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/loginPage.dart';
import 'package:flutter_demo/pages/search.dart';
import '../model/todoGet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Todo _todo;
  TextEditingController textEditingController;
  DateTime _dateTime;
  String request_url = "https://aodapi.eralpsoftware.net/";
  List<String> season = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık"
  ];
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();

    checkLoginStatus();
    // getTodoControl();
  }

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

      return _todo;
    }
  }

  void checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("/token/") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Yapılacaklar"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearch(),
              );
            },
            icon: Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => {
              sharedPreferences.remove("/token/"),
              sharedPreferences.remove("userId"),
              sharedPreferences.remove("username"),
              sharedPreferences.remove("name"),
              // sharedPreferences.clear(),
              // sharedPreferences.commit(),
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (route) => false)
            },
            icon: Icon(
              Icons.logout,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_showBottomSheet(context)},
        child: Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder(
          future: getTodoControl(),
          builder: (context, AsyncSnapshot<Todo> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data.body.length,
                  itemBuilder: (context, index) {
                    final String dateTime =
                        snapshot.data.body[index].date.day.toString() +
                            " " +
                            season[snapshot.data.body[index].date.month - 1] +
                            " " +
                            snapshot.data.body[index].date.year.toString() +
                            " " +
                            snapshot.data.body[index].date.hour.toString() +
                            ":" +
                            snapshot.data.body[index].date.minute.toString();
                    return Card(
                      child: ListTile(
                        title: Text(snapshot.data.body[index].name),
                        subtitle: Text(dateTime),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteTodo(snapshot.data.body[index].id);
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            } else if (!snapshot.hasData) {
              return Text("");
            }
          },
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext cntx) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      )),
      context: cntx,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 5, left: 10, right: 10),
          height: MediaQuery.of(context).size.height / 5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  fillColor: Colors.grey,
                  hintText: "Yeni kullanıcı adınızı giriniz",
                ),
              ),
              btnSection("TODO EKLE")
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton btnSection(String txt) {
    return RaisedButton(
      color: Colors.lime,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        txt,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      onPressed: () {
        _dateTime = DateTime.now();
        _postTodo(textEditingController.text, _dateTime);
      },
    );
  }

  _postTodo(String todo, DateTime date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final response = await http.post(request_url + "todo",
        body: jsonEncode({
          "name": todo,
          "date": date.toIso8601String(),
        }),
        headers: {
          "content-type": "application/json",
          "token": sharedPreferences.getString("/token/")
        });
    if (response.statusCode == 200) {
      setState(() {
        textEditingController.text = "";

        Navigator.pop(context);
      });
    }
  }

  _deleteTodo(int id) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final response = await http.delete(request_url + "todo/$id", headers: {
      "content-type": "application/json",
      "token": sharedPreferences.getString("/token/")
    });
    if (response.statusCode == 200) {
      setState(() {
        setState(() {});
      });
    }
  }
}

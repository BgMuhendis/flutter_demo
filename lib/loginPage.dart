import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/profilePage.dart';
import 'model/todoGet.dart';
import 'model/userGet.dart';
import 'pages/routerPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Todo _todo;
  TextEditingController textEditingController;
  User _user;
  String request_url = "https://aodapi.eralpsoftware.net/";
  SharedPreferences sharedPreferences;
  String _username, _password;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController = TextEditingController();
    _tokenControl();
  }

  _tokenControl() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("/token/") != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => RouterPage()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Container(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(4),
                        child: ListView(
                          children: [
                            txtEmail("Username"),
                            txtPassword("Password"),
                            btnSection("Sign In")
                          ],
                        ),
                      ),
              )),
        ),
      ),
    );
  }

  TextFormField txtEmail(String value) {
    return TextFormField(
      controller: textEditingController,
      onSaved: (newValue) {
        _username = newValue;
      },
      validator: _emailControl,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: value,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  TextFormField txtPassword(String value) {
    return TextFormField(
      onSaved: (newValue) {
        _password = newValue;
      },
      validator: _passwordControl,
      obscureText: true,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        fillColor: Colors.white,
        hintText: value,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  RaisedButton btnSection(String txt) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        txt,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
      ),
      onPressed: () {
        setState(() {
          _isLoading = true;
        });
        _loginInfoVerify(_username, _password);
      },
    );
  }

  String _emailControl(String value) {
    if (value.contains("@")) {
      return null;
    } else if (value.isEmpty) {
      return "Username boş geçilemez";
    }
    return "Geçersiz bir email adresi";
  }

  String _passwordControl(String value) {
    if (value.length == 6) {
      return null;
    } else if (value.isEmpty) {
      return "Password boş geçilemez";
    }
    return "Şifreniz 6 karakterli olmalıdır";
  }

  void _loginInfoVerify(String username, String password) async {
    print("dksofdsf");
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var jsonData = null;
      sharedPreferences = await SharedPreferences.getInstance();
      var response = await http.post(request_url + "login/apply",
          body: jsonEncode(
            {"username": _username, "password": _password},
          ),
          headers: {
            "content-type": "application/json",
          });
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        setState(() {
          _isLoading = false;
          sharedPreferences.setInt("userId", jsonData["userId"]);
          sharedPreferences.setString("/token/", jsonData["token"]);
          _getUser();
          _getTodo();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => RouterPage()),
              (route) => false);
        });
      } else {
        setState(() {
          _isLoading = false;
          textEditingController.text = _username;
        });
        _snackBarShow(response.body);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _snackBarShow(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(milliseconds: 2000), content: Text(message)));
  }

  _getUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var get_response = await http.get(
      request_url + "user/${sharedPreferences.getInt("userId")}",
      headers: {
        "content-type": "application/json",
        "token": sharedPreferences.getString("/token/"),
      },
    );
    if (get_response.statusCode == 200) {
      var decodedJson = json.decode(get_response.body);
      _user = User.fromMap(decodedJson);
      sharedPreferences.setString("username", _user.data[0].username);
      sharedPreferences.setString("name", _user.data[0].fullname);

      // Map map = json.decode(response1.body);
      // Map user = map["data"][0];

    }
  }

  _getTodo() async {
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
      print(_todo.body[0].name);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/model/userGet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../loginPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User _user;
  String newUserName;
  final _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController;
  String _userName = null, _name = null;
  final String request_url = "https://aodapi.eralpsoftware.net/";
  bool _loading = false, loading = false;
  String _city = null;
  SharedPreferences sharedPreferences;
  File _image;
  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }


  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _userInfoControl();
  }

  _userInfoControl() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("city") != null) {
      setState(() {
        _city = sharedPreferences.getString("city");
      });
    }
    if (sharedPreferences.getString("username") != null) {
      setState(() {
        _userName = sharedPreferences.getString("username");
      });
    }
    if (sharedPreferences.getString("name") != null) {
      setState(() {
        _name = sharedPreferences.getString("name");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _name != null ? Text(_name) : Text(""),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: MediaQuery.of(context).size.height / 2.1,
          width: MediaQuery.of(context).size.width / 1.1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 80.0,
                    backgroundImage: _image != null
                        ? FileImage(_image)
                        : AssetImage("assets/user.jpg"),
                  ),
                  Positioned(
                    bottom: 10.0,
                    right: 10.0,
                    child: InkWell(
                      onTap: getImage,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black54,
                        size: MediaQuery.of(context).size.height / 20,
                      ),
                    ),
                  ),
                ],
              ),
              sizedBox(),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName != null ? "Kullanıcı adı: " : "",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => _showBottomSheet(context),
                      child: Text(
                        _userName != null ? _userName : "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
              sizedBox(),
              RaisedButton(
                  color: Colors.lime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Location Search",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    getUserLocation();
                  }),
              sizedBox(),
              _loading
                  ? CircularProgressIndicator()
                  : Text(
                      _city != null ? "Şehir:  $_city" : "",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      setState(() {
        _loading = false;
        _city = "${placemark.locality}";
        sharedPreferences.setString("city", _city);
      });
      // String completeAddress =
      //     '${placemark.subThoroughfare} ${placemark.thoroughfare} ${placemark.subLocality} ${placemark.locality} ${placemark.subAdministrativeArea} ${placemark.administrativeArea} ${placemark.postalCode} ${placemark.country}';

      // String formattedAddress = "${placemark.locality}";
    }
  }

  Widget sizedBox() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 45,
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
      builder: (context) => Container(
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
            btnSection("DEGİSTİR")
          ],
        ),
      ),
    );
  }

  RaisedButton btnSection(String txt) {
    return RaisedButton(
      color: Colors.lime,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        txt,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      onPressed: () {
        put_request(textEditingController.text);
      },
    );
  }

  put_request(String username) async {
    sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.put(
      request_url + "user/${sharedPreferences.getInt("userId")}",
      body: jsonEncode(
        {"username": username},
      ),
      headers: {
        "content-type": "application/json",
        "token": sharedPreferences
            .getString("/token/"), // token = Login işleminden dönen token
      },
    );
    if (response.statusCode == 200) {
      _getUser();
    }
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
      sharedPreferences.remove("/token/");
      sharedPreferences.remove("userId");
      sharedPreferences.remove("username");
      sharedPreferences.remove("name");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (route) => false);
    }
  }
}

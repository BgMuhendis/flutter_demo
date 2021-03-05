import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/homePage.dart';
import 'package:flutter_demo/pages/profilePage.dart';

class RouterPage extends StatefulWidget {
  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();
  List<Widget> _screen = [HomePage(), ProfilePage()];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
    void _onPageChanged(int index) {}

    void _onItemTapped(int selectedIndex) {
      _pageController.jumpToPage(selectedIndex);
      setState(() {
        _selectedIndex = selectedIndex;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screen,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), title: Text("Anasayfa")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profil")),
        ],
      ),
    );
  }
}

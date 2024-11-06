
import 'package:chatapp/Chats/HomeChat.dart';
import 'package:chatapp/Story/StartHomeStory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
    final String currentUserId;

  const MainPage({super.key, required this.currentUserId});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user; // تأكد من تهيئة المستخدم لاحقًا
  late List<Widget> _pages; // استخدم late لأننا سنقوم بتهيئته لاحقًا

  @override
  void initState() {
    super.initState();
    _getUser(); // احصل على المستخدم عند بدء الصفحة
  }

  Future<void> _getUser() async {
    User? currentUser = auth.currentUser; // احصل على المستخدم الحالي
    if (currentUser != null) {
      setState(() {
        user = currentUser; // احفظ المستخدم في الحالة
        _pages = [ // قم بتهيئة _pages هنا
          HomeChat(currentUserId: user.uid),
          StartHomeStory(currentUserId:widget.currentUserId,)
        ];
      });
    } else {
      print("No user is currently signed in."); // التعامل مع الحالة
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        body: _pages[_selectedIndex], // استخدم _pages هنا
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GNav(
                  curve: Curves.easeOutExpo,
                  rippleColor: Colors.grey,
                  hoverColor: Colors.grey,
                  haptic: true,
                  tabBorderRadius: 20,
                  gap: 2,
                  activeColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.blue.withOpacity(0.7),
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  tabs: [
                    GButton(
                      iconSize: _selectedIndex != 0 ? 28 : 25,
                      icon: _selectedIndex == 0 ? Icons.chat : Icons.chat_bubble,
                      text: 'chats',
                    ),
                    GButton(
                      iconSize: _selectedIndex != 0 ? 28 : 25,
                      icon: _selectedIndex == 0 ? Icons.chat : Icons.chat_bubble,
                      text: 'story',
                    ),
                  
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

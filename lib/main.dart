import 'package:flutter/material.dart';
import 'package:news_app/Screens/Discover.dart';
import 'package:news_app/Screens/Home.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currentIndex = 0;

  final List<Widget> _screen = [
    HomeScreen(),
    DiscoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _screen[_currentIndex],
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          itemPadding: EdgeInsets.all(15),
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home), 
              title: Text("Home"),
              selectedColor: Colors.grey
              ),
            SalomonBottomBarItem(
              icon: Icon(Icons.explore), 
              title: Text("Explore"),
              selectedColor: Colors.grey
              ),
            ]
          ),
        ),
    );
  }
}
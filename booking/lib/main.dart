import 'package:flutter/material.dart';
import 'package:booking/bottom_navigation_bar.dart';


void main(){
  runApp(MyApp());

}
class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,

      home: BottomNavigationScreen(),
    );
  }
}

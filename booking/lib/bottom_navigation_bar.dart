import 'package:flutter/material.dart';
import 'package:booking/movies_screen.dart';
import 'package:booking/profile_screen.dart';
import 'package:booking/ticket_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  List<Widget> screens = [MoviesScreen(), TicketScreen(), ProfileScreen()];
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        animationDuration: Duration(seconds: 0),
        indicatorColor: Color(0xffFFB4AB),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentPageIndex = value;
            bool _hasNotification = true;
          });
        },
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.movie_outlined),
            icon: Badge(child: Icon(Icons.movie_outlined)),
            label: 'Movies',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.confirmation_number_outlined,),
            icon: Badge(child: Icon(Icons.confirmation_number_outlined)),
            label: 'Tickets',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_outline),
            icon: Badge(child: Icon(Icons.person_outline)),
            label: 'Profile',
          ),
        ],
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

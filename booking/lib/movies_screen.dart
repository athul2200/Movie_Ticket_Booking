import 'package:flutter/material.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CINE-NOIR",
          style: TextStyle(
            color: Color(0xffFFB4AB),
            fontSize: 24,
            fontFamily: "Inter",
            letterSpacing: -1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xffFFB4AB),
              ),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircleAvatar(
                radius: 2,
                backgroundImage: NetworkImage("C:/ATHUL/profile-pic.png"),

              ),
            ),
          ),
        ],
      ),
    );
  }
}

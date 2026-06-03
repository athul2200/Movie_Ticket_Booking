import 'package:flutter/material.dart';

class UserTable extends StatelessWidget {
  const UserTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6D2D2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Profiles",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Active member directory focusing on tier status and engagement.",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE6D2D2)),
                bottom: BorderSide(color: Color(0xFFE6D2D2)),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("MEMBER")),
                Expanded(child: Text("MOVIES\nSEEN")),
                Expanded(child: Text("TOTAL\nBOOKINGS")),
                Expanded(child: Text("FAVORITE\nGENRE")),
                Expanded(child: Text("ACTIONS")),
              ],
            ),
          ),

          buildRow(
            "JD",
            "Julianne Devis",
            "julianne.d@example.com",
            "45",
            "32",
            "Sci-Fi",
          ),

          buildRow(
            "MW",
            "Marcus Wright",
            "m.wright@cinema.com",
            "12",
            "8",
            "Action",
          ),

          buildRow(
            "SC",
            "Sarah Chen",
            "schen.creative@ui.com",
            "8",
            "5",
            "Drama",
          ),

          buildRow(
            "AK",
            "Aaron Kessler",
            "akessler@web.net",
            "0",
            "0",
            "N/A",
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: const Row(
              children: [

                Text(
                  "Showing 4 of 2,481 users",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                Spacer(),

                Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: Colors.grey,
                ),

                SizedBox(width: 8),

                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(
      String initials,
      String name,
      String email,
      String movies,
      String bookings,
      String genre,
      ) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
          ),
        ),
      ),
      child: Row(
        children: [

          Expanded(
            flex: 3,
            child: Row(
              children: [

                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF1F1F1),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(name),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: Text(movies)),
          Expanded(child: Text(bookings)),
          Expanded(child: Text(genre)),
          const Expanded(
            child: Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
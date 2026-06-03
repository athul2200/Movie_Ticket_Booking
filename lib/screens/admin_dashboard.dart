import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'header_bar.dart';
import 'user_table.dart';
import 'review_section.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),

          Expanded(
            child: Column(
              children: [
                const HeaderBar(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        UserTable(),
                        ReviewSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
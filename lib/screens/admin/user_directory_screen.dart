import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/user_model.dart';
import 'custom_card.dart';

class UserDirectoryScreen extends StatefulWidget {
  const UserDirectoryScreen({super.key});

  @override
  State<UserDirectoryScreen> createState() => _UserDirectoryScreenState();
}

class _UserDirectoryScreenState extends State<UserDirectoryScreen> {
  String _searchQuery = '';

  List<UserModel> get _filteredUsers {
    return MockData.users.where((user) {
      return _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Directory',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(
                width: 260,
                height: 40,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search user...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF6F6),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _headerText('NAME & EMAIL')),
                      Expanded(flex: 2, child: _headerText('PHONE')),
                      Expanded(flex: 2, child: _headerText('TIER')),
                      Expanded(flex: 2, child: _headerText('FAV GENRE')),
                      Expanded(flex: 2, child: _headerText('STATUS')),
                    ],
                  ),
                ),
                if (users.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No users found.',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  ...users.asMap().entries.map((entry) {
                    final user = entry.value;
                    final isLast = entry.key == users.length - 1;
                    return Column(
                      children: [
                        _buildUserRow(user),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
        color: AppTheme.textPrimary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildUserRow(UserModel user) {
    Color statusBg, statusText;
    if (user.status == 'ACTIVE') {
      statusBg = AppTheme.successGreenBg;
      statusText = AppTheme.successGreen;
    } else if (user.status == 'PENDING') {
      statusBg = AppTheme.warningYellowBg;
      statusText = AppTheme.warningYellow;
    } else {
      statusBg = AppTheme.errorRedBg;
      statusText = AppTheme.errorRed;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Name & Email
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightRed,
                  child: Text(
                    user.initials,
                    style: const TextStyle(color: AppTheme.darkRed, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Phone
          Expanded(
            flex: 2,
            child: Text(
              user.phone,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
          // Tier
          Expanded(
            flex: 2,
            child: Text(
              user.tier,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
          // Fav Genre
          Expanded(
            flex: 2,
            child: Text(
              user.favGenre,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.status,
                  style: TextStyle(
                    color: statusText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

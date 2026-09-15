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

  Future<void> _toggleUserStatus(UserModel user) async {
    final nextStatus = user.status == 'ACTIVE' ? 'BANNED' : 'ACTIVE';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(nextStatus == 'BANNED' ? 'Ban User Account' : 'Reactivate User Account'),
        content: Text('Are you sure you want to change "${user.name}" status to $nextStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nextStatus == 'BANNED' ? AppTheme.errorRed : AppTheme.successGreen,
            ),
            child: Text(nextStatus == 'BANNED' ? 'Ban Account' : 'Reactivate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final index = MockData.users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      setState(() {
        MockData.users[index] = user.copyWith(status: nextStatus);
      });
      await MockData.saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} is now $nextStatus.'),
            backgroundColor: nextStatus == 'BANNED' ? AppTheme.errorRed : AppTheme.successGreen,
          ),
        );
      }
    }
  }

  void _showUserDetails(UserModel user) {
    final userBookings = MockData.bookings.where((b) => b.userName.toLowerCase() == user.name.toLowerCase() || b.userEmail.toLowerCase() == user.email.toLowerCase()).toList();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.lightRed,
                    child: Text(user.initials, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkRed)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.status == 'ACTIVE' ? AppTheme.successGreenBg : AppTheme.errorRedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.status,
                      style: TextStyle(
                        color: user.status == 'ACTIVE' ? AppTheme.successGreen : AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  _infoCell('PHONE', user.phone),
                  _infoCell('TIER', user.tier),
                  _infoCell('FAVORITE GENRE', user.favGenre),
                  _infoCell('LAST ACTIVE', user.lastActive),
                  _infoCell('MOVIES SEEN', '${user.moviesSeenCount}'),
                  _infoCell('BOOKINGS RECORDED', '${userBookings.length}'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _toggleUserStatus(user);
                    },
                    icon: Icon(user.status == 'ACTIVE' ? Icons.block : Icons.check_circle, size: 16),
                    label: Text(user.status == 'ACTIVE' ? 'Ban Account' : 'Reactivate'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCell(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Directory',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active member directory focusing on tier status, engagement and account status.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(
                width: 260,
                height: 40,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search user by name/email...',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 850,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF6F6),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('MEMBER', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('STATUS', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('TIER', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('LAST ACTIVE', style: _headerStyle(context))),
                          Expanded(flex: 1, child: Text('ACTIONS', style: _headerStyle(context))),
                        ],
                      ),
                    ),
                    if (users.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('No users matching search query.')),
                      )
                    else
                      ...users.asMap().entries.map((entry) {
                        final user = entry.value;
                        final isLast = entry.key == users.length - 1;
                        return Column(
                          children: [
                            _buildUserRow(context, user),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                        border: Border(top: BorderSide(color: AppTheme.borderLight)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Showing ${users.length} of ${MockData.users.length} users', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppTheme.textSecondary,
        );
  }

  Widget _buildUserRow(BuildContext context, UserModel user) {
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
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightRed,
                  child: Text(user.initials, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.darkRed)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      Text(user.email, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.tier, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(user.lastActive, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () => _showUserDetails(user),
              tooltip: 'User Details',
            ),
          ),
        ],
      ),
    );
  }
}

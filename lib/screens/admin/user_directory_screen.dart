import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'custom_card.dart';

class UserDirectoryScreen extends StatelessWidget {
  const UserDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildUserProfiles(context),
    );
  }

  Widget _buildUserProfiles(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Profiles',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Active member directory focusing on tier status and engagement.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        const CustomCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700,
              child: UserProfilesTable(),
            ),
          ),
        ),
      ],
    );
  }
}

class UserProfilesTable extends StatelessWidget {
  const UserProfilesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Expanded(flex: 2, child: Text('MEMBER', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('STATUS', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('TIER', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('LAST ACTIVE', style: _headerStyle(context))),
            ],
          ),
        ),
        _buildRow(context, 'JD', 'Julianne Devis', 'julianne.d@example.com', 'ACTIVE', 'Platinum', '2h ago'),
        const Divider(height: 1),
        _buildRow(context, 'MW', 'Marcus Wright', 'm.wright@cinema.com', 'PENDING', 'Gold', '1d ago'),
        const Divider(height: 1),
        _buildRow(context, 'SC', 'Sarah Chen', 'schen.creative@ui.com', 'ACTIVE', 'Silver', '5m ago'),
        const Divider(height: 1),
        _buildRow(context, 'AK', 'Aaron Kessler', 'akessler@web.net', 'BANNED', 'None', '12d ago'),
        
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
              Text('Showing 4 of 2,481 users', style: Theme.of(context).textTheme.bodySmall),
              Row(
                children: [
                  _buildPageButton(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _buildPageButton(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle? _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: AppTheme.textSecondary,
    );
  }

  Widget _buildRow(BuildContext context, String initials, String name, String email, String status, String tier, String lastActive) {
    Color statusBg, statusText;
    if (status == 'ACTIVE') {
      statusBg = AppTheme.successGreenBg;
      statusText = AppTheme.successGreen;
    } else if (status == 'PENDING') {
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
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightRed,
                  child: Text(initials, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.darkRed)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      Text(email, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(tier, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text(lastActive, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: AppTheme.textSecondary),
    );
  }
}

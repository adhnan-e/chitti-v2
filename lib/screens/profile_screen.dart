import 'package:flutter/material.dart';
import 'package:chitt/services/auth_service.dart';
import 'package:chitt/core/design/tokens/tokens.dart';
import 'package:chitt/core/design/components/components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final userName = currentUser?['fullName'] ??
        currentUser?['username'] ??
        'User';
    final phone = currentUser?['phone'] ?? '+91 98765 43210';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: Spacing.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Profile',
                    style: AppTypography.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Text(
                      'Edit',
                      style: AppTypography.buttonMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: Spacing.screenPadding,
                child: Column(
                  children: [
                    const VSpace.lg(),

                    // Profile Avatar
                    AppAvatar(
                      initials: initials,
                      size: AppAvatarSize.xl,
                    ),
                    const VSpace.lg(),

                    // User Name
                    Text(
                      userName,
                      style: AppTypography.headlineLarge,
                    ),
                    const VSpace.xs(),
                    Text(
                      phone,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const VSpace.xxl(),

                    // Menu Items
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          AppListTile(
                            leading: AppListTileIcon(
                              icon: Icons.account_balance_wallet,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'My Chittis',
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/chitti_list');
                            },
                            showDivider: true,
                          ),
                          AppListTile(
                            leading: AppListTileIcon(
                              icon: Icons.table_rows,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: 'My Slots',
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const VSpace.xxl(),

                    // Logout Button
                    AppButton.danger(
                      label: 'Logout',
                      leadingIcon: Icons.logout,
                      fullWidth: true,
                      onPressed: () {
                        AuthService().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

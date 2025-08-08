import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/providers/auth.provider.dart';
import 'package:transit_lanka/shared/constants/colors.dart';

enum SideBarItem { routes, schedules, map, profile, settings, logout }

class SideBar extends StatelessWidget {
  final SideBarItem selectedItem;
  final Function(SideBarItem) onItemSelected;
  final VoidCallback onCloseDrawer;

  const SideBar({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onCloseDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              accountName: Text(
                user?.name ?? "Driver",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(
                user?.email ?? "driver@example.com",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.secondaryLight,
                backgroundImage: user?.profileImageUrl != null
                    ? NetworkImage(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            _buildDrawerItem(
              icon: Icons.route,
              title: 'Routes',
              isSelected: selectedItem == SideBarItem.routes,
              onTap: () {
                onItemSelected(SideBarItem.routes);
                onCloseDrawer();
              },
            ),
            _buildDrawerItem(
              icon: Icons.schedule,
              title: 'Schedules',
              isSelected: selectedItem == SideBarItem.schedules,
              onTap: () {
                onItemSelected(SideBarItem.schedules);
                onCloseDrawer();
              },
            ),
            _buildDrawerItem(
              icon: Icons.map,
              title: 'Map',
              isSelected: selectedItem == SideBarItem.map,
              onTap: () {
                onItemSelected(SideBarItem.map);
                onCloseDrawer();
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              isSelected: selectedItem == SideBarItem.profile,
              onTap: () {
                onItemSelected(SideBarItem.profile);
                onCloseDrawer();
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              isSelected: selectedItem == SideBarItem.settings,
              onTap: () {
                onItemSelected(SideBarItem.settings);
                onCloseDrawer();
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              isSelected: selectedItem == SideBarItem.logout,
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppColors.primaryLight.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }
}

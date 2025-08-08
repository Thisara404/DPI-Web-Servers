import 'package:flutter/material.dart';
import 'package:transit_lanka/shared/constants/colors.dart';

enum DriverTabItem {
  routes,
  schedules,
  map,
  profile,
}

class DriverTabBar extends StatelessWidget {
  final DriverTabItem selectedTab;
  final Function(DriverTabItem) onTabSelected;

  const DriverTabBar({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65, // Increased height to accommodate content
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(
            context: context,
            item: DriverTabItem.routes,
            icon: Icons.route,
            title: 'Routes',
          ),
          _buildTabItem(
            context: context,
            item: DriverTabItem.schedules,
            icon: Icons.schedule,
            title: 'Schedules',
          ),
          _buildTabItem(
            context: context,
            item: DriverTabItem.map,
            icon: Icons.map,
            title: 'Map',
          ),
          _buildTabItem(
            context: context,
            item: DriverTabItem.profile,
            icon: Icons.person,
            title: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required DriverTabItem item,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedTab == item;
    final color = isSelected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () => onTabSelected(item),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              MainAxisAlignment.center, // Center items vertically
          children: [
            Icon(icon, color: color, size: 22), // Slightly smaller icon
            const SizedBox(height: 2), // Reduced spacing
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 11, // Slightly smaller text
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

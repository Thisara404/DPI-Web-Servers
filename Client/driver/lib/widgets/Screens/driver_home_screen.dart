import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/providers/auth.provider.dart';
import 'package:transit_lanka/screens/driver/screens/schedule.screen.dart';
import 'package:transit_lanka/screens/driver/screens/map.screen.dart';
import 'package:transit_lanka/screens/driver/screens/profile.screen.dart'; // Import the profile screen
import 'package:transit_lanka/screens/driver/widgets/common/app.bar.dart';
import 'package:transit_lanka/screens/driver/widgets/common/side.bar.dart';
import 'package:transit_lanka/screens/driver/widgets/common/tab.bar.dart';
import 'package:transit_lanka/screens/driver/screens/routes.screen.dart';
import 'package:transit_lanka/core/providers/schedule.provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DriverTabItem _currentTab = DriverTabItem.routes;
  SideBarItem _currentSideBarItem = SideBarItem.routes;

  // Map tab items to their corresponding titles
  final Map<DriverTabItem, String> _tabTitles = {
    DriverTabItem.routes: 'Routes',
    DriverTabItem.schedules: 'Schedules',
    DriverTabItem.map: 'Map',
    DriverTabItem.profile: 'Profile',
  };

  // Map sidebar items to their corresponding titles
  final Map<SideBarItem, String> _sidebarTitles = {
    SideBarItem.routes: 'Routes',
    SideBarItem.schedules: 'Schedules',
    SideBarItem.map: 'Map',
    SideBarItem.profile: 'Profile',
    SideBarItem.settings: 'Settings',
    SideBarItem.logout: 'Logout',
  };

  // Get the current screen title based on selected item
  String get _currentTitle {
    return _sidebarTitles[_currentSideBarItem] ?? 'Transit Lanka Driver';
  }

  @override
  void initState() {
    super.initState();
    // Check for active schedule and switch to map tab if found
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForActiveSchedule();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check for arguments to select a specific tab
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('selectedTab')) {
      final selectedTab = args['selectedTab'];
      if (selectedTab == 'map') {
        setState(() {
          _currentTab = DriverTabItem.map;
          _currentSideBarItem = SideBarItem.map;
        });
      } else if (selectedTab == 'profile') {
        setState(() {
          _currentTab = DriverTabItem.profile;
          _currentSideBarItem = SideBarItem.profile;
        });
      }
    }
  }

  void _checkForActiveSchedule() {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    // Check if there's an in-progress schedule
    final hasActiveSchedule = scheduleProvider.schedules
        .any((schedule) => schedule.status == 'in-progress');

    // If there's an active schedule, switch to map tab
    if (hasActiveSchedule) {
      setState(() {
        _currentTab = DriverTabItem.map;
        _currentSideBarItem = SideBarItem.map;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DriverAppBar(
        title: _currentTitle,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: SideBar(
        selectedItem: _currentSideBarItem,
        onItemSelected: _selectSideBarItem,
        onCloseDrawer: () => _scaffoldKey.currentState?.closeDrawer(),
      ),
      body: _buildBody(),
      bottomNavigationBar: DriverTabBar(
        selectedTab: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }

  void _selectTab(DriverTabItem tabItem) {
    setState(() {
      _currentTab = tabItem;
      // Sync sidebar selection with tab selection
      switch (tabItem) {
        case DriverTabItem.routes:
          _currentSideBarItem = SideBarItem.routes;
          break;
        case DriverTabItem.schedules:
          _currentSideBarItem = SideBarItem.schedules;
          break;
        case DriverTabItem.map:
          _currentSideBarItem = SideBarItem.map;
          break;
        case DriverTabItem.profile:
          _currentSideBarItem = SideBarItem.profile;
          break;
      }
    });
  }

  void _selectSideBarItem(SideBarItem item) {
    setState(() {
      _currentSideBarItem = item;
      // Sync tab selection with sidebar if applicable
      if (item == SideBarItem.routes) {
        _currentTab = DriverTabItem.routes;
      } else if (item == SideBarItem.schedules) {
        _currentTab = DriverTabItem.schedules;
      } else if (item == SideBarItem.map) {
        _currentTab = DriverTabItem.map;
      } else if (item == SideBarItem.profile) {
        _currentTab = DriverTabItem.profile;
      }
      // Note: Settings doesn't have a corresponding tab
    });
  }

  Widget _buildBody() {
    switch (_currentSideBarItem) {
      case SideBarItem.routes:
        return const RoutesScreen();
      case SideBarItem.schedules:
        return const ScheduleScreen();
      case SideBarItem.map:
        return const MapScreen();
      case SideBarItem.profile:
        return const DriverProfileScreen(); // Use the profile screen
      case SideBarItem.settings:
        return const Center(child: Text('Settings Screen'));
      case SideBarItem.logout:
        return const Center(child: Text('Logging out...'));
      default:
        return const RoutesScreen();
    }
  }
}

// Add a TabProvider for communication between screens
class TabProvider extends ChangeNotifier {
  DriverTabItem _currentTab = DriverTabItem.routes;

  DriverTabItem get currentTab => _currentTab;

  void switchToTab(DriverTabItem tab) {
    _currentTab = tab;
    notifyListeners();
  }
}

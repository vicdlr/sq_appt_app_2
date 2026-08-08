import 'package:flutter/material.dart';
import 'package:sq_notification/view/home/home_dashboard.dart';
import 'package:sq_notification/view/home/my_booking.dart';
import 'package:sq_notification/view/home/request_new_booking.dart';
import 'package:sq_notification/view/home/settings.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;
  List pages = [
    const HomeDashboard(),
    MyBooking(filterActiveQueuesOnly: true),
    RequestNewBooking(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.groups),
            icon: Icon(Icons.groups_outlined),
            label: 'My Queues',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_today),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Services',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.more_horiz),
            icon: Icon(Icons.more_horiz_outlined),
            label: 'More',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}



// class BottomNavBar extends StatefulWidget {
//   BottomNavBar({super.key});

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int selectedIndex = 0;
//   List pages = [
//     HomePage(),
//     GetTicket(),
//     MyBooking(),
//     RequestNewBooking(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (val) {
//           setState(() {
//             selectedIndex = val;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
//           BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ""),
//           BottomNavigationBarItem(icon: Icon(Icons.event_note), label: ""),
//           BottomNavigationBarItem(icon: Icon(Icons.factory), label: ""),
//         ],
//       ),
//     );
//   }
// }
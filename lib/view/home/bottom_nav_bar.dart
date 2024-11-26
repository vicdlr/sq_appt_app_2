import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/view/home/get_ticket.dart';
import 'package:sq_notification/view/home/home_page.dart';
import 'package:sq_notification/view/home/my_booking.dart';
import 'package:sq_notification/view/home/request_new_booking.dart';

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;
  List pages = [
    HomePage(),
    GetTicket(),
    MyBooking(),
    RequestNewBooking(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory),
            label: '',
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
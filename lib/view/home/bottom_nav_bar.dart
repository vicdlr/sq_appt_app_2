import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/api/dio.dart';
import 'package:sq_notification/view/home/get_ticket.dart';
import 'package:sq_notification/view/home/home_dashboard.dart';
import 'package:sq_notification/view/home/notification.dart';
import 'package:sq_notification/view/home/request_new_booking.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;
  List pages = [
    const HomeDashboard(),
    const NotificationsScreen(),
    RequestNewBooking(),
  ];

  // "More" (2026-08-28) no longer embeds a native screen -- it mints a token-bridged SSO link
  // (mirroring service_provider_mode.dart's _openCareConnect) into CareConnect's own "More" page
  // instead, so its content can grow without an app release. Settings (Appearance, Location,
  // Notifications, Language, Service Provider Mode, Account actions) is still fully reachable via
  // the Home screen's own profile menu -- see home_dashboard.dart/home_page.dart's "Settings" menu
  // item -- this just removes the redundant second gateway into it.
  Future<void> _openMore(BuildContext context) async {
    final result = await DioApi.post(path: ConfigUrl.moreLinkUrl, data: {});

    if (!context.mounted) return;
    if (DioConfig.maybeBlockForForceUpdate(context)) return;

    final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
    if (result.response != null && careConnectUrl != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WebViewPage(url: careConnectUrl, title: 'More');
      }));
    } else {
      Fluttertoast.showToast(msg: "Couldn't open this right now. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index == 3) {
            _openMore(context);
            return;
          }
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
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_today),
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Book',
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
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/api/dio.dart';
import 'package:sq_notification/notification/notification.dart';
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

  final NotificationServices _notificationServices = NotificationServices();

  // 2026-09-10, per the user (root-caused by Mac Claude): permission request, foreground
  // handling, tap-to-open, and token refresh (firebaseInit/setupInteractMessage/isTokenRefresh in
  // notification/notification.dart) were only ever wired up in lib/view/home/home_page.dart's
  // initState -- dead code since BottomNavBar switched to HomeDashboard on 2026-08-08 (commit
  // 2c51b1a). SignUp.dart's own getDeviceToken() call requests permission (so a fresh sign-up
  // still prompts), but never wires foreground/tap/refresh handling, and Login never requests
  // permission or a token at all -- so anyone who logs into an existing account (rather than
  // signing up fresh) never gets prompted, and nobody -- new or returning -- ever gets tap-to-open
  // (including the staff_reply fix) wired live. This is the actual live entry point after both
  // login and signup, and on every app relaunch while already authenticated -- porting
  // home_page.dart's updateFcmToken() logic here (minus its UI-only badge-token fetch, already
  // handled by HomeDashboard) fixes both gaps at once.
  Future<void> _initNotifications() async {
    _notificationServices.firebaseInit(context);
    _notificationServices.setupInteractMessage(context);
    _notificationServices.isTokenRefresh();
    final token = await _notificationServices.getDeviceToken();

    final sharedPrefFcm = SharedPref.getFcmToken();
    if (sharedPrefFcm != token) {
      final result = await DioApi.put(
        path: ConfigUrl.updateProfile,
        data: {"fcm_token": token},
      );
      if (result.response != null) {
        SharedPref.setFcmToken(token);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

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
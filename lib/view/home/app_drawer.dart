import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../provider/home_provider.dart';
import '../../utils/utils.dart';
import '../auth/SignUp.dart';
import 'get_ticket.dart';
import 'my_booking.dart';
import 'notification.dart';
import 'request_new_booking.dart';
import 'service_provider_mode.dart';
import 'settings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = SharedPref.getUserData();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userData.username),
              accountEmail: Text(userData.email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 36),
              ),
            ),
            _DrawerItem(
              icon: Icons.calendar_today_outlined,
              title: "Request New Booking",
              subtitle: "Find a service and request an appointment",
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<HomeProvider>(context, listen: false)
                    .setIndustriesEmpty();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RequestNewBooking();
                }));
              },
            ),
            _DrawerItem(
              icon: Icons.qr_code_scanner,
              title: "Get a Ticket",
              subtitle: "Scan a Get Ticket QR code to join a queue",
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return GetTicket();
                }));
              },
            ),
            _DrawerItem(
              icon: Icons.event_note,
              title: "My Bookings",
              subtitle: "View and manage your appointments and tickets",
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MyBooking();
                }));
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "View your alerts and important updates",
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NotificationsScreen();
                }));
              },
            ),
            const Divider(),
            if (userData.isServiceProvider)
              _DrawerItem(
                icon: Icons.storefront_outlined,
                title: "Service Provider Mode",
                subtitle: "Manage your queues as a service provider",
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const ServiceProviderMode();
                  }));
                },
              ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SettingsScreen();
                }));
              },
            ),
            _DrawerItem(
              icon: Icons.logout,
              title: "Log Out",
              onTap: () async {
                final bool isLogout = await Utils.logoutDialog(context) ?? false;
                if (isLogout) {
                  SharedPref.deleteData();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return const SignupPage();
                    }), (route) => false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Model/BookingModel.dart';
import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../constant/app_colors.dart';
import '../../provider/home_provider.dart';
import '../../utils/utils.dart';
import '../auth/SignUp.dart';
import 'app_drawer.dart';
import 'get_ticket.dart';
import 'home_page.dart';
import 'my_booking.dart';
import 'request_new_booking.dart';
import 'service_provider_mode.dart';
import 'settings.dart';

const Color kServiceProviderBlue = Color(0xFF1E4FA3);
const Color kServiceProviderBlueLight = Color(0xFFE9EEFA);

// The app's actual landing tab -- home_page.dart is kept as the dedicated full-screen Badge view
// (reached from this screen's badge card), not repurposed, since it already owns the fetch/cache
// logic for the badge token.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<HomeProvider>(context, listen: false).getAllBooking(context);
    });
  }

  BookingModel? _activeQueueBooking(List<BookingModel> bookings) {
    for (final booking in bookings) {
      if (booking.handledBy == "CARECONNECT" &&
          booking.status.toLowerCase() != "cancelled" &&
          booking.status.toLowerCase() != "completed") {
        return booking;
      }
    }
    return null;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return "there";
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _logout() async {
    final bool isLogout = await Utils.logoutDialog(context) ?? false;
    if (isLogout) {
      SharedPref.deleteData();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
          return const SignupPage();
        }), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);
    final userData = SharedPref.getUserData();
    final activeBooking = _activeQueueBooking(homeData.bookingList);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(
          children: [
            Image.asset("assets/images/smartq_logo.png", width: 34, height: 34),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("SmartQ",
                      style: TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Smarter Queues. Better Experience.",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            icon: const CircleAvatar(
              backgroundColor: kSmartQGreenLight,
              child: Icon(Icons.person, color: kSmartQGreen),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return const SettingsScreen();
                }));
              } else if (value == 'logout') {
                _logout();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<HomeProvider>(context, listen: false).getAllBooking(context),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "${_greeting()}, ${_firstName(userData.username)}!",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "SmartQ helps you save time by keeping you updated on your queue.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (activeBooking != null) _ActiveQueueCard(booking: activeBooking),
            if (activeBooking != null) const SizedBox(height: 20),
            Text("Quick Actions",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _QuickActionsGrid(),
            const SizedBox(height: 20),
            _BadgeFeatureCard(),
            const SizedBox(height: 16),
            userData.isServiceProvider ? _ServiceProviderPanel() : _RegisterServiceCard(),
          ],
        ),
      ),
    );
  }
}

class _ActiveQueueCard extends StatelessWidget {
  final BookingModel booking;

  const _ActiveQueueCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSmartQGreenLight,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: kSmartQGreen, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My Active Queues",
                  style: TextStyle(fontWeight: FontWeight.bold, color: kSmartQGreen)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return MyBooking();
                  }));
                },
                child: const Text("View all", style: TextStyle(color: kSmartQGreen)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.organisation.isNotEmpty ? booking.organisation : booking.unit,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(booking.status, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSmartQGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return MyBooking();
                }));
              },
              child: const Text("View Status"),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback Function(BuildContext context) onTap;

  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}

class _QuickActionsGrid extends StatelessWidget {
  static final List<_QuickAction> _actions = [
    _QuickAction(Icons.qr_code_scanner, "Get a Ticket", kSmartQGreen, (context) {
      return () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return GetTicket();
          }));
    }),
    _QuickAction(Icons.calendar_today_outlined, "Appointments", kServiceProviderBlue, (context) {
      return () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return MyBooking();
          }));
    }),
    _QuickAction(Icons.groups_outlined, "My Queues", const Color(0xFF7B3FA0), (context) {
      return () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return MyBooking(filterActiveQueuesOnly: true);
          }));
    }),
    _QuickAction(Icons.add_box_outlined, "New Booking", const Color(0xFFC9772E), (context) {
      return () {
        Provider.of<HomeProvider>(context, listen: false).setIndustriesEmpty();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return RequestNewBooking();
        }));
      };
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8,
      children: _actions.map((action) {
        return InkWell(
          onTap: action.onTap(context),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: action.color, shape: BoxShape.circle),
                child: Icon(action.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BadgeFeatureCard extends StatelessWidget {
  static const List<String> _uses = [
    "Check in using a SmartQ kiosk",
    "Check in with a receptionist",
    "Access and monitor your queue position",
    "Receive notifications when your turn is approaching",
  ];

  @override
  Widget build(BuildContext context) {
    final badgeToken = SharedPref.getBadgeToken();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSmartQGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text("SmartQ Badge / Pass",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Your digital pass for SmartQ-enabled services.",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  ..._uses.map((use) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(use,
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: badgeToken == null || badgeToken.isEmpty
                      ? const Icon(Icons.badge_outlined, color: kSmartQGreen)
                      : QrImageView(data: badgeToken, version: QrVersions.auto),
                ),
                const SizedBox(height: 6),
                const Text("TAP TO\nENLARGE",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceProviderPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kServiceProviderBlueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("For Service Providers",
              style: TextStyle(fontWeight: FontWeight.bold, color: kServiceProviderBlue)),
          const SizedBox(height: 4),
          const Text("Manage your queues, serving customers efficiently with SmartQ.",
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kServiceProviderBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return const ServiceProviderMode();
                }));
              },
              child: const Text("Switch to Service Provider Mode"),
            ),
          ),
        ],
      ),
    );
  }
}

// Shown instead of _ServiceProviderPanel for a regular customer -- links out to CareConnect's
// existing public clinic-registration form rather than building a second one natively, same
// "one implementation, many doorways" reasoning as the rest of the CareConnect link-outs.
class _RegisterServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kServiceProviderBlueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, color: kServiceProviderBlue, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text("Do you need to manage your Clients/Patients Queue?",
                    style: TextStyle(fontWeight: FontWeight.bold, color: kServiceProviderBlue)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                const TextSpan(text: "Register your Service/Clinic to CareConnect"),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Text("TM", style: TextStyle(fontSize: 8, color: Colors.black87)),
                ),
                const TextSpan(text: " and manage your own queue with SmartQ."),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kServiceProviderBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  // ccregister.smartqsys.com is CareConnect's dedicated subdomain for this public
                  // form (proxy.ts) -- ccuser/ccadmin explicitly don't serve it the same way.
                  return const WebViewPage(
                    url: "https://ccregister.smartqsys.com/register-clinic",
                  );
                }));
              },
              child: const Text("Register a Service"),
            ),
          ),
        ],
      ),
    );
  }
}

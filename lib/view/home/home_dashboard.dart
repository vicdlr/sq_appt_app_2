import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Model/BookingModel.dart';
import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../provider/home_provider.dart';
import 'app_drawer.dart';
import 'get_ticket.dart';
import 'home_page.dart';
import 'my_booking.dart';
import 'request_new_booking.dart';
import 'service_provider_mode.dart';

// The app's actual landing tab -- home_page.dart is kept as the dedicated full-screen Badge view
// (reached from this screen's badge preview card), not repurposed, since it already owns the
// fetch/cache logic for the badge token.
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

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);
    final userData = SharedPref.getUserData();
    final activeBooking = _activeQueueBooking(homeData.bookingList);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartQ"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
              "Good day, ${userData.username}!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              "SmartQ helps you save time by keeping you updated on your queue.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (activeBooking != null) _ActiveQueueCard(booking: activeBooking),
            if (activeBooking != null) const SizedBox(height: 16),
            _QuickActionsGrid(),
            const SizedBox(height: 16),
            _BadgePreviewCard(),
            if (userData.isServiceProvider) const SizedBox(height: 16),
            if (userData.isServiceProvider) _ServiceProviderPanel(),
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
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("My Active Queue",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MyBooking();
                    }));
                  },
                  child: const Text("View all"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(booking.organisation, style: Theme.of(context).textTheme.bodyLarge),
            Text(booking.status, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _QuickActionTile(
          icon: Icons.qr_code_scanner,
          label: "Get a Ticket",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return GetTicket();
            }));
          },
        ),
        _QuickActionTile(
          icon: Icons.calendar_today_outlined,
          label: "Appointments",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MyBooking();
            }));
          },
        ),
        _QuickActionTile(
          icon: Icons.add_box_outlined,
          label: "New Booking",
          onTap: () {
            Provider.of<HomeProvider>(context, listen: false).setIndustriesEmpty();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return RequestNewBooking();
            }));
          },
        ),
        _QuickActionTile(
          icon: Icons.badge_outlined,
          label: "My Queues",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MyBooking(filterActiveQueuesOnly: true);
            }));
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final badgeToken = SharedPref.getBadgeToken();
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: badgeToken == null || badgeToken.isEmpty
            ? const SizedBox(width: 48, height: 48, child: Icon(Icons.badge_outlined))
            : SizedBox(
                width: 48,
                height: 48,
                child: QrImageView(data: badgeToken, version: QrVersions.auto),
              ),
        title: const Text("SmartQ Badge / Pass",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Your digital pass for SmartQ-enabled services"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        },
      ),
    );
  }
}

class _ServiceProviderPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("For Service Providers",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Manage your queues, serving customers efficiently with SmartQ."),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const ServiceProviderMode();
                  }));
                },
                child: const Text("Switch to Service Provider Mode"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

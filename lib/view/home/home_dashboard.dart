import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Model/BookingModel.dart';
import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../api/api.dart';
import '../../api/configurl.dart';
import '../../api/dio.dart';
import '../../constant/app_colors.dart';
import '../../provider/home_provider.dart';
import '../../utils/utils.dart';
import '../auth/SignIn.dart';
import 'app_drawer.dart';
import 'get_ticket.dart';
import 'home_page.dart';
import 'notification.dart';
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
      // Substring-based, matching my_booking.dart's _statusKind -- a literal-equality check
      // against "cancelled"/"completed" missed statuses like "Request to Cancel" (set by
      // /cancel-booking on an already-CareConnect-rejected booking), which has no live queue
      // to view but isn't literally "Cancelled".
      final status = booking.status.toLowerCase();
      final isTerminal = status.contains("cancel") ||
          status.contains("declin") ||
          status.contains("reject") ||
          status.contains("complet") ||
          status.contains("served");
      if (booking.handledBy == "CARECONNECT" && !isTerminal) {
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
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return const LoginPage();
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
                  // Pinned regardless of the device's Dynamic Type setting -- this is the app's
                  // wordmark/branding in an already width-constrained toolbar, not reading
                  // content, so it shouldn't compete with the action icons for space.
                  const Text("SmartQ",
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                          color: kSmartQGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text("Smarter Queues. Better Experience.",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
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
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
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
        onRefresh: () => Provider.of<HomeProvider>(context, listen: false)
            .getAllBooking(context),
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
            _ActiveQueueCard(booking: activeBooking),
            const SizedBox(height: 20),
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
            userData.isServiceProvider
                ? _ServiceProviderPanel()
                : _ManageBookingsCard(),
          ],
        ),
      ),
    );
  }
}

class _ActiveQueueCard extends StatefulWidget {
  // Null when there's no active-today booking to show -- the card still renders (a
  // "No Active Queue Today" state) rather than disappearing, so there's always a way to reach
  // CareConnect's Queue Status page and its entertainment section underneath (2026-08-26).
  final BookingModel? booking;

  const _ActiveQueueCard({required this.booking});

  @override
  State<_ActiveQueueCard> createState() => _ActiveQueueCardState();
}

class _ActiveQueueCardState extends State<_ActiveQueueCard> {
  bool _isLoadingStatus = false;

  // With a booking: "View Status" is about *this* booking specifically, so it mints a focused
  // queue-access token (same bridge as my_booking.dart's _viewQueue -- lands on CareConnect's
  // Queue Status page focused on this booking) rather than the generic Manage Bookings link
  // "View all" uses, which has no concept of which booking to highlight.
  // Without a booking: there's no booking id to scope a queue-access token to, so this falls
  // back to the same session-token bridge "View all"/"Manage Bookings" use, tagged
  // source: 'queue_status' so CareConnect's consume route lands on Queue Status (with its own
  // "No Active Queue Today" empty state) instead of the full Manage Bookings list.
  Future<void> _viewStatus() async {
    setState(() => _isLoadingStatus = true);

    final booking = widget.booking;
    if (booking == null) {
      await _openManageBookings(context,
          source: 'queue_status',
          title: 'Queue Status',
          onLoaded: () {
        if (mounted) setState(() => _isLoadingStatus = false);
      });
      return;
    }

    final result = await DioApi.post(
        path: ConfigUrl.queueAccessUrl(booking.id.toString()), data: {});

    if (!mounted) return;
    setState(() => _isLoadingStatus = false);

    final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
    if (result.response != null && careConnectUrl != null) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return WebViewPage(url: careConnectUrl, title: 'Queue Status');
        }));
      }
    } else {
      Fluttertoast.showToast(
          msg: "Couldn't open the queue right now. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
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
              const Text("Queue Status",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: kSmartQGreen)),
              TextButton(
                onPressed: () => _openManageBookings(context),
                child: const Text("View all",
                    style: TextStyle(color: kSmartQGreen)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (booking != null) ...[
            Text(
                booking.organisation.isNotEmpty
                    ? booking.organisation
                    : booking.unit,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(booking.status, style: Theme.of(context).textTheme.bodySmall),
          ] else
            Text("No Active Queue Today",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSmartQGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoadingStatus ? null : _viewStatus,
              child: _isLoadingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(booking != null ? "View Status" : "Queue Status"),
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
    _QuickAction(Icons.qr_code_scanner, "Get a Ticket", kSmartQGreen,
        (context) {
      return () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return GetTicket();
          }));
    }),
    // Routes to CareConnect's Manage Bookings WebView (same SSO-minted link as the
    // "Manage Your Bookings" card below), not the app's own MyBooking() list -- confirmed
    // 2026-08-15 that node_app_server's own booking pool and CareConnect's are separate, and
    // CareConnect is taking over booking management from the app, so this is the single
    // source of truth for a user's appointments going forward.
    _QuickAction(
        Icons.calendar_today_outlined, "Appointments", kServiceProviderBlue,
        (context) {
      return () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        await _openManageBookings(context, source: 'appointments', onLoaded: () {
          if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
        });
      };
    }),
    _QuickAction(
        Icons.notifications_outlined, "Notifications", const Color(0xFF7B3FA0),
        (context) {
      return () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const NotificationsScreen();
          }));
    }),
    _QuickAction(Icons.add_box_outlined, "New Booking", const Color(0xFFC9772E),
        (context) {
      return () {
        if (DioConfig.maybeBlockForForceUpdate(context)) return;
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
                decoration:
                    BoxDecoration(color: action.color, shape: BoxShape.circle),
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

class _BadgeFeatureCard extends StatefulWidget {
  @override
  State<_BadgeFeatureCard> createState() => _BadgeFeatureCardState();
}

class _BadgeFeatureCardState extends State<_BadgeFeatureCard> {
  static const List<String> _uses = [
    "Check in using a SmartQ kiosk",
    "Check in with a receptionist",
    "Access and monitor your queue position",
    "Receive notifications when your turn is approaching",
  ];

  String? _badgeToken;

  @override
  void initState() {
    super.initState();
    _badgeToken = SharedPref.getBadgeToken();
    _fetchBadgeToken();
  }

  // Fetches independently of the full-screen Badge view (home_page.dart) so the preview here
  // shows a live QR on first load too, instead of only after the user has visited that screen at
  // least once and populated the cache.
  Future<void> _fetchBadgeToken() async {
    final result = await DioApi.get(path: ConfigUrl.getBadgeTokenUrl);
    if (result.response != null) {
      final String? freshToken = result.response?.data["data"]?["badgeToken"];
      if (freshToken != null && freshToken.isNotEmpty) {
        SharedPref.setBadgeToken(freshToken);
        if (mounted) setState(() => _badgeToken = freshToken);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeToken = _badgeToken;
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
                      Icon(Icons.shield_outlined,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text("SmartQ Badge / Pass",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
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
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(use,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
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
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: kServiceProviderBlue)),
          const SizedBox(height: 4),
          const Text(
              "Manage your queues, serving customers efficiently with SmartQ.",
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
    );
  }
}

// Shown instead of _ServiceProviderPanel for a regular customer. Was previously a "Register a
// Service" card linking out to CareConnect's public clinic-registration form -- removed from the
// app entirely (2026-08-09, user request) so the app itself doesn't surface business/clinic
// onboarding; that form still lives on ccregister.smartqsys.com, just not linked from here.
// Replaced with a consumer-facing action instead: opens the patient's CareConnect bookings
// (ccuser) via a token-minted SSO link (node_app_server's /careconnect/manage-bookings-link,
// mirroring the queue-access bridge's mint/consume pattern), so there's no separate ccuser
// login step from inside the app.
// Shared by the "Appointments" Quick Action and _ManageBookingsCard -- both open the same
// CareConnect SSO-minted view (node_app_server's /careconnect/manage-bookings-link). CareConnect
// now auto-provisions an account on a device's first call (2026-08-15) instead of 404ing when
// there's no CareConnect account yet, so this always lands on CareConnect (its /bookings list,
// empty for a brand-new account) rather than needing a "no bookings yet" special case here.
// `onLoaded` fires once the network call resolves, before navigation/toast, so callers with their
// own loading UI (a button spinner, a blocking dialog) can dismiss it at the right time.
Future<void> _openManageBookings(BuildContext context,
    {VoidCallback? onLoaded, String? source, String title = 'Manage Bookings'}) async {
  final result = await DioApi.post(
      path: ConfigUrl.manageBookingsLinkUrl,
      data: source != null ? {"source": source} : {});

  onLoaded?.call();

  if (context.mounted && DioConfig.maybeBlockForForceUpdate(context)) return;

  final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
  if (result.response != null && careConnectUrl != null) {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WebViewPage(url: careConnectUrl, title: title);
      }));
    }
  } else {
    Fluttertoast.showToast(
        msg: "Couldn't open $title right now. Please try again.");
  }
}

class _ManageBookingsCard extends StatefulWidget {
  @override
  State<_ManageBookingsCard> createState() => _ManageBookingsCardState();
}

class _ManageBookingsCardState extends State<_ManageBookingsCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);
    await _openManageBookings(context, source: 'manage_bookings', onLoaded: () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSmartQGreenLight,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_note_outlined, color: kSmartQGreen, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text("Manage Your Bookings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: kSmartQGreen)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "View and manage all your CareConnect bookings and queue status in one place.",
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSmartQGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _handleTap,
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Manage Bookings"),
            ),
          ),
        ],
      ),
    );
  }
}

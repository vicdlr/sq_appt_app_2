import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../api/api.dart';
import '../../api/configurl.dart';
import '../../api/dio.dart';
import 'get_ticket.dart';

// Native shell around CareConnect's own ccadmin pages -- queue handling/monitoring logic lives
// entirely in CareConnect (one implementation, reusable by any future channel, not just this
// app), this screen is just navigation into it via WebView. See get_ticket.dart's WebViewPage,
// reused directly rather than building a second WebView wrapper.
//
// Each card mints a token-bridged SSO link first (node_app_server's
// /careconnect/service-provider-link, mirroring home_dashboard.dart's _openManageBookings for
// ccuser) instead of opening ccadmin directly -- 2026-08-19, per the user: mobile access should
// never hit ccadmin's own login wall, but a normal browser going straight to ccadmin must still
// require the usual password login (untouched by this change; this is purely an additional way
// to obtain the same session).
class ServiceProviderMode extends StatefulWidget {
  const ServiceProviderMode({super.key});

  @override
  State<ServiceProviderMode> createState() => _ServiceProviderModeState();
}

class _ServiceProviderModeState extends State<ServiceProviderMode> {
  bool _isLoading = false;

  Future<void> _openCareConnect(BuildContext context, String next, String title) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final result = await DioApi.post(
        path: ConfigUrl.serviceProviderLinkUrl, data: {"next": next});

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!context.mounted) return;
    if (DioConfig.maybeBlockForForceUpdate(context)) return;

    final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
    if (result.response != null && careConnectUrl != null) {
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return WebViewPage(url: careConnectUrl, title: title);
        }));
      }
    } else {
      Fluttertoast.showToast(msg: "Couldn't open $title right now. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Provider Mode"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuickLinkCard(
            icon: Icons.people_outline,
            title: "View Queues",
            subtitle: "See who's waiting and manage your queue",
            onTap: () => _openCareConnect(context, "clinic", "View Queues"),
          ),
          const SizedBox(height: 12),
          _QuickLinkCard(
            icon: Icons.confirmation_number_outlined,
            title: "Now Serving",
            subtitle: "Call the next client and track current status",
            onTap: () => _openCareConnect(context, "clinic", "Now Serving"),
          ),
          const SizedBox(height: 12),
          _QuickLinkCard(
            icon: Icons.history,
            title: "Queue History",
            subtitle: "Review past appointments and bookings",
            onTap: () => _openCareConnect(context, "bookings", "Queue History"),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

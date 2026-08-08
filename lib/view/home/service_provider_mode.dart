import 'package:flutter/material.dart';

import '../../api/configurl.dart';
import 'get_ticket.dart';

// Native shell around CareConnect's own ccadmin pages -- queue handling/monitoring logic lives
// entirely in CareConnect (one implementation, reusable by any future channel, not just this
// app), this screen is just navigation into it via WebView. See get_ticket.dart's WebViewPage,
// reused directly rather than building a second WebView wrapper.
class ServiceProviderMode extends StatelessWidget {
  const ServiceProviderMode({super.key});

  void _openCareConnect(BuildContext context, String path) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WebViewPage(
        url: "${ConfigUrl.careConnectAdminBaseUrl}$path?embedded=1",
      );
    }));
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
            onTap: () => _openCareConnect(context, "/admin/clinic"),
          ),
          const SizedBox(height: 12),
          _QuickLinkCard(
            icon: Icons.confirmation_number_outlined,
            title: "Now Serving",
            subtitle: "Call the next client and track current status",
            onTap: () => _openCareConnect(context, "/admin/clinic"),
          ),
          const SizedBox(height: 12),
          _QuickLinkCard(
            icon: Icons.history,
            title: "Queue History",
            subtitle: "Review past appointments and bookings",
            onTap: () => _openCareConnect(context, "/admin/clinic/bookings"),
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

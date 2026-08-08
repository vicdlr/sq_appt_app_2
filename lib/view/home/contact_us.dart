import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/SignIn.dart';

const String _supportEmail = "support@smartqsys.com";

// "Live Chat" and "Call Us" from the mockup are deliberately omitted for now (per the user) --
// only Email Support and Help Center are wired up. Both "Email Support" and "Send a Message"
// just open the device's own email client via mailto: -- no in-app form, no backend endpoint,
// so there's nothing here that can silently drop a submission the way contact.html's broken web
// form does.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _openMailto(String subject) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: "No email app available on this device");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        foregroundColor: kSmartQGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSmartQGreenLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("We're Here to Help!",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: kSmartQGreen, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                    "Have a question, need support, or want to give feedback? We'd love to hear from you."),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text("Best way to reach us",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: kSmartQGreen, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kSmartQGreenLight,
                child: Icon(Icons.email_outlined, color: kSmartQGreen),
              ),
              title: const Text("Email Support", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("$_supportEmail\nWe typically respond within 24 hours."),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openMailto("SmartQ Support Request"),
            ),
          ),
          const SizedBox(height: 20),
          Text("Other ways to contact us",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: kSmartQGreen, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kSmartQGreenLight,
                child: Icon(Icons.help_outline, color: kSmartQGreen),
              ),
              title: const Text("Help Center", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Browse articles and FAQs"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Fluttertoast.showToast(msg: "Help Center is coming soon"),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSmartQGreenLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: kSmartQGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Your satisfaction matters",
                          style: TextStyle(fontWeight: FontWeight.bold, color: kSmartQGreen)),
                      SizedBox(height: 4),
                      Text(
                          "We are committed to providing you with the best support experience possible. Thank you for being part of SmartQ!"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

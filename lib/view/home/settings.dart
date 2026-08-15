import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/constant/app_colors.dart';
import 'package:sq_notification/utils/utils.dart';
import 'package:sq_notification/view/auth/SignUp.dart';
import 'package:sq_notification/view/home/contact_us.dart';
import 'package:sq_notification/view/home/service_provider_mode.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../provider/theme_provider.dart';
import 'WebView.dart';

const List<String> _supportedLanguages = ["English"];
const Color kDestructiveRed = Color(0xFFD32F2F);
const Color kDestructiveRedLight = Color(0xFFFDEAEA);
const Color kAccountActionsOrange = Color(0xFFC9772E);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local preferences only for now -- no backend behavior is gated by these yet (e.g. push
  // sending doesn't check notificationsEnabled, no localization framework reads language). Kept
  // shallow deliberately until an actual feature needs them; visible and persisted so the UI is
  // truthful about what's been chosen.
  bool _notificationsEnabled = SharedPref.getNotificationsEnabled();
  String _language = SharedPref.getLanguage();

  Future<void> deleteAccount() async {
    final result =
        await DioApi.delete(path: ConfigUrl.deleteUserUrl(SharedPref.getUserData().id));

    if (result.response == null) {
      result.handleError(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ThemeProvider>(context, listen: false).getRegionData();
    });
  }

  Future<void> _showPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ...options.map((option) => ListTile(
                    title: Text(option),
                    trailing: option == currentValue
                        ? const Icon(Icons.check, color: kSmartQGreen)
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelected(option);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showNotificationPreferences() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notification Preferences",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Push Notifications"),
                    subtitle: const Text("Booking updates and queue alerts"),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setSheetState(() {});
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      SharedPref.setNotificationsEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action is irreversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteAccount();
                SharedPref.deleteData();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return const SignupPage();
                  }), (route) => false);
                }
              },
              child: const Text("Yes", style: TextStyle(color: kDestructiveRed)),
            ),
          ],
        );
      },
    );
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final userData = SharedPref.getUserData();

    return Scaffold(
      appBar: AppBar(
        // No explicit `leading` -- Flutter's automaticallyImplyLeading (default true) shows a
        // back/close button only when this route can actually be popped. Settings is reached two
        // ways: pushed as a standalone route (e.g. the Badge page's gear icon), where a close
        // button makes sense, and embedded directly as bottom_nav_bar.dart's "More" tab body
        // (index-swapped, not pushed), where there's nothing to pop -- an unconditional pop()
        // here previously popped the bottom-nav screen itself off the stack, leaving a black
        // screen behind it.
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Customize your SmartQ experience",
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _SettingsSection(
            title: "APPEARANCE",
            children: [
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                subtitle: "Use a darker theme for low light",
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (bool value) => themeProvider.toggleTheme(),
                ),
              ),
              _SettingsRow(
                icon: Icons.text_fields,
                title: "Font Size",
                subtitle: "Adjust text size for better readability",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("A", style: TextStyle(fontSize: 12)),
                    SizedBox(
                      width: 90,
                      child: Slider(
                        divisions: 35,
                        min: 14,
                        max: 35,
                        value: themeProvider.fSize,
                        onChanged: (double value) => themeProvider.setFontSize(value),
                      ),
                    ),
                    const Text("A", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: "PREFERENCES",
            children: [
              _SettingsRow(
                icon: Icons.location_on_outlined,
                title: "Location / Region",
                subtitle: "Set your location for local services",
                trailingText: userData.city.isNotEmpty ? userData.city : "Not set",
                onTap: () => _showPicker(
                  title: "Select your city",
                  options: themeProvider.cityDropDown,
                  currentValue: userData.city,
                  onSelected: (city) {
                    themeProvider.setSelectedCity({"city": city}).then((_) => setState(() {}));
                  },
                ),
              ),
              _SettingsRow(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                subtitle: "Manage your notification preferences",
                onTap: _showNotificationPreferences,
              ),
              _SettingsRow(
                icon: Icons.language_outlined,
                title: "Language",
                subtitle: "Choose your preferred language",
                trailingText: _language,
                onTap: () => _showPicker(
                  title: "Select language",
                  options: _supportedLanguages,
                  currentValue: _language,
                  onSelected: (lang) {
                    setState(() {
                      _language = lang;
                    });
                    SharedPref.setLanguage(lang);
                  },
                ),
              ),
              if (userData.isServiceProvider)
                _SettingsRow(
                  icon: Icons.storefront_outlined,
                  title: "Service Provider Mode",
                  subtitle: "Manage your queues as a service provider",
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return const ServiceProviderMode();
                    }));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: "ACCOUNT & PRIVACY",
            children: [
              _SettingsRow(
                icon: Icons.lock_outline,
                title: "Privacy Policy",
                subtitle: "How we collect, use, and protect your data",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/privacy.html',
                      title: 'Privacy Policy',
                    );
                  }));
                },
              ),
              _SettingsRow(
                icon: Icons.description_outlined,
                title: "Terms of Use",
                subtitle: "Terms and conditions for using SmartQ",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/terms.html',
                      title: 'Terms & Conditions',
                    );
                  }));
                },
              ),
              _SettingsRow(
                icon: Icons.info_outline,
                title: "About Us",
                subtitle: "Learn more about SmartQ Systems",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/about.html',
                      title: 'About Us',
                    );
                  }));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: "ACCOUNT ACTIONS",
            titleColor: kAccountActionsOrange,
            children: [
              _SettingsRow(
                icon: Icons.logout,
                iconColor: kAccountActionsOrange,
                iconBg: const Color(0xFFFBEADD),
                title: "Logout",
                subtitle: "Sign out from your SmartQ account",
                onTap: _logout,
              ),
              _SettingsRow(
                icon: Icons.delete_outline,
                iconColor: kDestructiveRed,
                iconBg: kDestructiveRedLight,
                title: "Delete Account",
                titleColor: kDestructiveRed,
                subtitle: "Permanently delete your account and data",
                destructive: true,
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSmartQGreenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent_outlined, color: kSmartQGreen),
              title: const Text("Need Help?",
                  style: TextStyle(fontWeight: FontWeight.bold, color: kSmartQGreen)),
              subtitle: const Text("Visit our Help Center or contact support"),
              trailing: const Icon(Icons.open_in_new, color: kSmartQGreen),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return const ContactUsScreen();
                }));
              },
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Center(
                  child: Text(
                    'Version: ${snapshot.data!.version}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    this.titleColor = kSmartQGreen,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                  color: titleColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
            ),
          ),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingsRow({
    required this.icon,
    this.iconColor = kSmartQGreen,
    this.iconBg = kSmartQGreenLight,
    required this.title,
    this.titleColor,
    required this.subtitle,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: destructive ? kDestructiveRedLight : null,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
        subtitle: Text(subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12)),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null) ...[
                  ConstrainedBox(
                    // Caps the trailing value (e.g. a long city name) so it can't squeeze the
                    // title/subtitle column down to near-zero width, which forces Text to wrap
                    // one character per line instead of truncating.
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      trailingText!,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (onTap != null)
                  Icon(Icons.chevron_right, color: destructive ? kDestructiveRed : Colors.grey),
              ],
            ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/constant/firebase_constant.dart';
import 'package:sq_notification/notification/notification.dart';
import 'package:sq_notification/constant/app_colors.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/provider/theme_provider.dart';
import 'package:sq_notification/view/home/request_new_booking.dart';
import 'package:sq_notification/view/home/settings.dart';

import '../../SharedPrefrence/SharedPrefrence.dart';
import 'get_ticket.dart';
import 'my_booking.dart';
import 'notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationServices notification = NotificationServices();
  String fcmToken = "";
  String? badgeToken;

  void updateData(String token) async {
    var data = {
      "fcm_token": token,
    };

    final result = await DioApi.put(path: ConfigUrl.updateProfile, data: data);

    if (result.response != null) {
      print("user updated successfully === ${result.response?.data}");
      SharedPref.setFcmToken(fcmToken);
    } else {
      result.handleError(context);
    }
  }

  Future<void> updateFcmToken() async {
    notification.forgroundMessage();
    notification.firebaseInit(context);
    notification.setupInteractMessage(context);
    notification.isTokenRefresh();
    final String token = await notification.getDeviceToken();

    print("token +++ $token");

    setState(() {
      fcmToken = token ?? "";
    });

    final sharedPrefFcm = SharedPref.getFcmToken();
    print("Shared pref fcm == $sharedPrefFcm");

    if (sharedPrefFcm != fcmToken) {
      updateData(fcmToken);

      // print("currentUserid ==  ${firebaseAuth.currentUser?.uid}");
      // print("fcmToken ==  $token");
      // final DocumentReference colRef =
      //     firestore.doc("users/${firebaseAuth.currentUser?.uid}");
      //
      // final DocumentSnapshot snapshot = await colRef.get();
      //
      // if (snapshot.exists) {
      //   await colRef.update({'fcmToken': token});
      //   print('FCM token updated successfully');
      // } else {
      //   print('User document does not exist');
      // }
    }
  }

  // Renders instantly from cache (works offline), then refreshes silently in the background --
  // the badge is meant to keep working even if the phone has no signal at the moment it's shown.
  Future<void> fetchAndCacheBadgeToken() async {
    setState(() {
      badgeToken = SharedPref.getBadgeToken();
    });

    final result = await DioApi.get(path: ConfigUrl.getBadgeTokenUrl);
    if (result.response != null) {
      final String? freshToken = result.response?.data["data"]?["badgeToken"];
      if (freshToken != null && freshToken.isNotEmpty) {
        SharedPref.setBadgeToken(freshToken);
        setState(() {
          badgeToken = freshToken;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateFcmToken();
    fetchAndCacheBadgeToken();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    //print(" QR cusotmer ID =  ${SharedPref.getUserData().customerId}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "SmartQ Badge",
          style: TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kSmartQGreen),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                child: Text('Request New Booking'),
                value: 'request_booking',
              ),
              const PopupMenuItem(
                child: Text('Get a Ticket'),
                value: 'get_ticket',
              ),
              const PopupMenuItem(
                child: Text('Get Appointment'),
                value: 'get_appointment',
              ),
              const PopupMenuItem(
                child: Text('Notification'),
                value: 'notification',
              ),
            ],
            onSelected: (value) {
              if (value == 'request_booking') {
                Provider.of<HomeProvider>(context, listen: false)
                    .setIndustriesEmpty();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return RequestNewBooking();
                }));
              } else if (value == 'get_ticket') {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return GetTicket();
                }));
              } else if (value == "get_appointment") {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MyBooking();
                }));
              } else if (value == "notification") {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NotificationsScreen();
                }));
              }
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Soft brand-green wash top-left and a wave along the bottom, echoing the mockup's
          // gradient backdrop without needing a custom-painted asset.
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSmartQGreenLight,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: kSmartQGreenLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(120),
                  topRight: Radius.circular(120),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Image.asset("assets/images/smartq_logo.png",
                        width: 64, height: 64),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "SmartQ",
                            style: TextStyle(
                              color: kSmartQGreen,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " Badge",
                            style: TextStyle(
                              color: Color(0xFF6FBF8B),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Your SmartQ Badge",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSmartQGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Show this QR code to check in at any SmartQ-enabled location.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 28),
                    _ScannerFramedQr(badgeToken: badgeToken),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSmartQGreenLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock,
                                color: kSmartQGreen, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Secure & Private",
                                  style: TextStyle(
                                    color: kSmartQGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Your information is encrypted and never shared.",
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        text: "Powered by ",
                        style: TextStyle(color: Colors.grey.shade600),
                        children: const [
                          TextSpan(
                            text: "SmartQ",
                            style: TextStyle(
                                color: kSmartQGreen,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// White QR card with green scanner-style corner brackets, matching the reference mockup. Falls
// back to an explanatory message (instead of a blank/broken QR) when the badge hasn't been
// fetched yet -- happens on first-ever launch before the device has been online once.
class _ScannerFramedQr extends StatelessWidget {
  final String? badgeToken;

  const _ScannerFramedQr({required this.badgeToken});

  @override
  Widget build(BuildContext context) {
    const double size = 240;
    final hasToken = badgeToken != null && badgeToken!.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size - 32,
              height: size - 32,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: hasToken
                  ? QrImageView(
                      data: badgeToken!,
                      version: QrVersions.auto,
                    )
                  : Center(
                      child: Text(
                        "Connect to the internet once to activate your badge",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
            ),
          ),
          _cornerBracket(top: 0, left: 0),
          _cornerBracket(top: 0, right: 0),
          _cornerBracket(bottom: 0, left: 0),
          _cornerBracket(bottom: 0, right: 0),
        ],
      ),
    );
  }

  Widget _cornerBracket(
      {double? top, double? bottom, double? left, double? right}) {
    const double length = 28;
    const double thickness = 3;
    final bool isTop = top != null;
    final bool isLeft = left != null;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: length,
        height: length,
        child: Stack(
          children: [
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              child: Container(
                  width: length, height: thickness, color: kSmartQGreen),
            ),
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              child: Container(
                  width: thickness, height: length, color: kSmartQGreen),
            ),
          ],
        ),
      ),
    );
  }
}

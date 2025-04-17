// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/constant/firebase_constant.dart';
import 'package:sq_notification/notification/notification.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    //print(" QR cusotmer ID =  ${SharedPref.getUserData().customerId}");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "SmartQ Badge",
        ),
        centerTitle: true,
        actions: [
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
        leading: PopupMenuButton(
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
              child: Text('My Bookings'),
              value: 'get_appointment',
            ),
            const PopupMenuItem(
              child: Text('Notifications'),
              value: 'notification',
            ),
          ],
          onSelected: (value) {
            if (value == 'request_booking') {
              Provider.of<HomeProvider>(context, listen: false)
                  .setIndustriesEmpty();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return RequestNewBooking();
              }));
            } else if (value == 'get_ticket') {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return GetTicket();
              }));
            } else if (value == "get_appointment") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MyBooking();
              }));
            } else if (value == "notification") {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NotificationsScreen();
              }));
            }
          },
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: fcmToken.isEmpty
              ? const CircularProgressIndicator()
              : QrImageView(
                  //data: "${firebaseAuth.currentUser?.uid}  $fcmToken",
                  data: "${SharedPref.getUserData().customerId}$fcmToken",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
        ),
      ),
    );
  }
}

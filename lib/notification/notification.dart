import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/provider/home_provider.dart';



class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Fixed channel id/name -- must match node_app_server's FCM_ANDROID_CHANNEL_ID so every push
  // (foreground-displayed here, and background/killed-app pushes Android auto-displays straight
  // from the FCM payload) lands on the same channel. Pre-creating this once at app startup (see
  // initNotificationChannel below) is what lets a user actually customize its sound via Android's
  // own per-channel notification settings screen -- a channel's sound is locked the moment it's
  // first created, and showNotification() used to create it on the fly from whatever the very
  // first push happened to send, so it could never hold a stable, user-changeable sound.
  static const String bookingUpdatesChannelId = 'booking_updates';
  static const String _channelName = 'Booking Updates';
  static const String _channelDescription =
      'Queue and booking status alerts (confirmations, check-ins, your turn, staff replies)';

  // Pre-creates the app's one notification channel before any push can arrive, so its sound
  // setting starts out stable and user-editable from the first notification onward. Call once at
  // startup (main.dart), before runApp -- creating it lazily inside showNotification() is exactly
  // the bug this replaces.
  Future<void> initNotificationChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      bookingUpdatesChannelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Opens Android's own per-app-channel notification settings screen (Settings > Apps > SmartQ >
  // Notifications > Booking Updates), where the user can pick any sound already on their device
  // for this channel -- no in-app sound picker or bundled sound assets needed. iOS has no
  // equivalent system screen (Apple doesn't expose per-app sound choice at all), so this is
  // Android-only by design; callers should guard the UI entry point with Platform.isAndroid too.
  Future<void> openNotificationSoundSettings() async {
    if (!Platform.isAndroid) return;

    final packageName = (await PackageInfo.fromPlatform()).packageName;
    final intent = AndroidIntent(
      action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': packageName,
        'android.provider.extra.CHANNEL_ID': bookingUpdatesChannelId,
      },
    );
    try {
      await intent.launch();
    } catch (e) {
      // This app's minSdkVersion (23) predates notification channels (API 26) -- on those older
      // devices there's no Settings activity to handle CHANNEL_NOTIFICATION_SETTINGS at all, so
      // the platform throws rather than silently no-opping. Also covers any OEM Settings-app
      // quirk that breaks the same way. A toast beats a silent dead tap or an uncaught crash.
      if (kDebugMode) {
        print('failed to open notification channel settings: $e');
      }
      await Fluttertoast.showToast(
          msg: "Notification sound settings aren't available on this device.");
    }
  }

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    int msgCount = 0 ;
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {

          msgCount++;
          print("msgcount ===  $msgCount");
          handleMessage(context, message);
        });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {

        print("noti title:${notification!.title}");
        print("badges :$notification");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if (Platform.isIOS) {

        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  void requestNotificationPermission() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }


  // function to show visible notification when app is active

  Future<void> showNotification(RemoteMessage message) async {

    // Always uses the fixed, pre-created bookingUpdatesChannelId -- not
    // message.notification.android.channelId -- so display always goes through the one channel
    // whose sound the user can actually change (see initNotificationChannel above). The server
    // already sends this same channel id (FCM_ANDROID_CHANNEL_ID in node_app_server), so this
    // isn't a behavior change for a correctly-configured backend, just removes the client's own
    // dependence on trusting/recreating a channel per message.
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      bookingUpdatesChannelId, _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    int msgCount = 0;
    Future.delayed(Duration.zero, () {
      msgCount++;
      print("msgcount ===  $msgCount");
      _flutterLocalNotificationsPlugin.show(
        0,
        message.
        notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('user granted provisional permission');
      }
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('user denied permission');
      }
    }

    String? token = await messaging.getToken();

    return token!;
  }

  bool containsWord(String input, String targetWord) {
    return input.toLowerCase().contains(targetWord.toLowerCase());
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('fcm token refreshed: $newToken');
      }
      updateFcmTokenOnServer(newToken);
    });
  }

  // /login never touches fcmtoken, so this is what keeps the server-side token fresh once it rotates.
  Future<void> updateFcmTokenOnServer(String token) async {
    final result = await DioApi.post(
      path: ConfigUrl.updateFcmTokenUrl,
      data: {"fcm_token": token},
    );

    if (result.response != null) {
      SharedPref.setFcmToken(token);
      if (kDebugMode) {
        print('fcm token updated on server');
      }
    } else if (kDebugMode) {
      print('failed to update fcm token on server: ${result.dioError}');
    }
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }


    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) async {


    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context){
    //   return MyApp();
    // },route : false));


    print(message.notification!.title.toString());
    print("message.data == ${message.data["data"]}");

    String type = message.data["type"]?.toString() ?? "";
    String typeId = message.data["_id"]?.toString() ?? "";

    // Booking-related push tap -> open the related booking directly (2026-09-07, per the user)
    // instead of just opening the app to wherever it already was. Patient-facing types carry NAS's
    // own numeric booking id (externalBookingId on newer sends, bookingId on the pre-existing
    // booking_confirmed/booking_checked_in/booking_processing sends from applyCareConnectOutcome --
    // both mean the same id, just added under two different keys over time); staff-facing types
    // carry CareConnect's own uuid instead, a different id-space entirely.
    // "staff_reply" added 2026-09-10 (CareConnect's app/api/admin/service/bookings/[id]/messages
    // route.ts, staff replying in the Counter's Client Messages panel) -- was missing here, so
    // tapping that notification fell through to the default (just open the app to Home) instead
    // of opening the actual booking/chat, per the user's bug report.
    const patientBookingTypes = {"booking_confirmed", "booking_checked_in", "booking_processing", "your_turn", "staff_reply"};
    const staffBookingTypes = {"new_booking", "support_ticket"};
    if (patientBookingTypes.contains(type)) {
      final id = message.data["externalBookingId"] ?? message.data["bookingId"];
      if (id != null && context.mounted) {
        await Provider.of<HomeProvider>(context, listen: false)
            .openPatientBookingFromNotification(context, id.toString());
      }
      return;
    }
    if (staffBookingTypes.contains(type)) {
      final id = message.data["bookingId"];
      if (id != null && context.mounted) {
        await Provider.of<HomeProvider>(context, listen: false)
            .openStaffBookingFromNotification(context, id.toString());
      }
      return;
    }

    // if(message.notification!.title.toString() == "Group added"){}

    // if (message.notification!.title.toString() == "Group Connection Request") {
    //   try {
    //     String groupDataString = message.data["data"] ?? "";
    //     var groupData = jsonDecode(groupDataString);
    //
    //     String groupId = groupData ?? "";
    //
    //     if (groupId.isNotEmpty) {
    //
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => GroupChat(groupChatId: groupId),
    //         ),
    //       );
    //     } else {
    //
    //       print("Group ID is empty or missing in the notification data.");
    //     }
    //   } catch (e) {
    //
    //     print("Error parsing Group Connection Request data: $e");
    //   }
    // }

    // if (message.notification!.title.toString() == "Group Connection Request") {
    //   try {
    //     String groupDataString = message.data["data"] ?? "";
    //     var groupData = jsonDecode(groupDataString);
    //
    //     String groupId = groupData ?? "";
    //
    //     if (groupId.isNotEmpty) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => GroupChat(groupChatId: groupId),
    //         ),
    //       );
    //     } else {
    //       print("Group ID is empty or missing in the notification data.");
    //     }
    //   } catch (e) {
    //
    //     print("Error parsing Group Connection Request data: $e");
    //   }
    // }

    // if (message.notification!.title.toString() == "Group request accepted") {
    //   try {
    //     String groupDataString = message.data["data"] ?? "";
    //     var groupData = jsonDecode(groupDataString);
    //
    //     String groupId = groupData ?? "";
    //
    //     if (groupId.isNotEmpty) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => GroupChat(groupChatId: groupId),
    //         ),
    //       );
    //     } else {
    //       print("Group ID is empty or missing in the notification data.");
    //     }
    //   } catch (e) {
    //
    //     print("Error parsing Group Connection Request data: $e");
    //   }
    // }

    // if (message.notification!.title.toString() == "New Connection Request") {
    //   // Map<String ,dynamic> data = jsonDecode(message.data.toString() ?? "");
    //   Map<String ,dynamic> connectionData = jsonDecode(message.data["data"].toString());
    //
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => PendingRequestProfileTab(
    //         chatUserId: connectionData["requestId"] ?? "",
    //         name: connectionData["fullName"] ?? "",
    //         about: connectionData["about"] ?? '',
    //         age: connectionData["age"] ?? '',
    //         martial: connectionData["maritalStatus"] ?? '',
    //         gender: connectionData["gender"] ?? '',
    //         address: connectionData["address"] ?? '',
    //         image: connectionData["image"] ?? '',
    //       ),
    //     ),
    //   );
    // }


    // if(message.notification!.title.toString() == "Group Connection Request"){
    //
    //   String groupData = message.data["data"] ?? "";
    //
    //   Map<String ,dynamic> connectionData = jsonDecode(message.data["data"].toString());
    //
    //   String groupId = connectionData["data"] ?? "";
    //
    //   Navigator.push(
    //       context,MaterialPageRoute(
    //     builder: (context) => GroupChat(groupChatId: groupId),
    //   ));
    // }

    // if (type == "chat") {
    //   DocumentSnapshot docSnapshot =
    //   await FirebaseFirestore.instance.collection("users").doc(typeId).get();
    //
    //   Map<String, dynamic> docMap = docSnapshot.data() as Map<String, dynamic>;
    //
    //   List<dynamic> fcmTokenList = docMap["fcmToken"] as List<dynamic>;
    //   List<String> stringList = [];
    //
    //   for (var item in fcmTokenList) {
    //     if (item is String) {
    //       stringList.add(item);
    //     } else {
    //       // Handle the case where the item is not a string
    //       // You can choose to ignore it or handle it differently
    //     }
    //   }
    //
    //   ChatUser chatUser = ChatUser(
    //     id: typeId ?? "",
    //     name: docMap["fullName"] ?? "",
    //     about: docMap["about"] ?? "",
    //     image: docMap["image"]?? "",
    //     lastActive: docMap["lastActive"] ?? "",
    //     createdAt: docMap["createdAt"].toString() ?? "",
    //     isOnline: docMap["isOnline"] ?? "",
    //     pushToken: stringList ,
    //     email: docMap["email"] ?? "",
    //   );
    //
    //   // Navigator.push(
    //   //     context,MaterialPageRoute(
    //   //   builder: (context) => ChatScreen(user: chatUser),
    //   // ));
    // }

    // if (type == "group") {
    //
    //   print("typeId $typeId");
    //   Navigator.push(
    //       context,MaterialPageRoute(
    //     builder: (context) => GroupChat(groupChatId: typeId),
    //   ));
    // }

  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

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

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id.toString(), channel.name.toString(),
      channelDescription: 'your channel description',
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
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
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

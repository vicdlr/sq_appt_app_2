import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/provider/theme_provider.dart';
import 'package:sq_notification/view/auth/SignUp.dart';
import 'package:sq_notification/view/home/bottom_nav_bar.dart';
import 'firebase_options.dart';

double globalFontSize = 0.0;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SharedPref.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (BuildContext context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => HomeProvider()),
      ],
      child:  MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print(message.notification!.title.toString());
  print(message.notification!.body.toString());
  print(message.data.toString());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ThemeProvider>(context, listen: false).getThemeData();
    });
    globalFontSize = double.parse(SharedPref.getFonts().toString());
  }

  @override
  Widget build(BuildContext context) {
    //log("profile details ${SharedPref.getUserData()}");
    return Consumer<ThemeProvider>(
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Sq notifications',
          theme: value.themeData,
          home: SharedPref.getAuthToken() != null
              ? BottomNavBar()
              : const SignupPage(),
        );
      },
    );
  }
}

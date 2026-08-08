import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/Model/CityModel.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:country_state_city/country_state_city.dart' as data;
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/constant/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData;

  List<CityModel> cities = [];

  List<String> cityDropDown = [];

  bool isDarkTheme = false;
  double fSize = 14;

  ThemeProvider() {
    isDarkTheme = SharedPref.getTheme();
    _themeData = isDarkTheme ? darkMode(fSize) : lightMode(fSize);
    getThemeData();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (isDarkTheme == false) {
      themeData = darkMode(fSize);
      isDarkTheme = true;
      SharedPref.setDarkTheme(true);
    } else {
      SharedPref.setDarkTheme(false);
      themeData = lightMode(fSize);
      isDarkTheme = false;
    }
    notifyListeners();
  }

  void getThemeData() {
    isDarkTheme = SharedPref.getTheme();
    fSize = SharedPref.getFonts();
    themeData = isDarkTheme ? darkMode(fSize) : lightMode(fSize);
  }

  void setFontSize(double size) {
    fSize = size;
    SharedPref.setFonts(size);
    themeData = isDarkTheme ? darkMode(fSize) : lightMode(fSize);
    notifyListeners();
  }

  Future<void> getRegionData() async {
    final result = await DioApi.get(path: ConfigUrl.getCityurl);
    if (result.response != null) {
      cities = (result.response?.data["cities"] as List<dynamic>)
          .map((data) => CityModel.fromJson(data))
          .toList();
      cityDropDown = cities.map((data) => data.city).toList();
      print("city == $cityDropDown");
      notifyListeners();
    } else {}
  }

  Future<void> setSelectedCity(var dataProfile) async {
    final result =
        await DioApi.put(path: ConfigUrl.updateProfile, data: dataProfile);
    if (result.response != null) {
      await Fluttertoast.showToast(msg: "Updated successfully");
      final userData = SharedPref.getUserData();
      userData.city = result.response?.data["city"];
      SharedPref.setUserData(userData);
    } else {}
  }
}

ThemeData lightMode(double fSize) => ThemeData(
      brightness: Brightness.light,
      dialogBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: (fSize + 20),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: (fSize),
        ),
        titleMedium: TextStyle(
          fontSize: (fSize),
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontSize: (fSize),
          color: Colors.black,
        ),
        labelMedium: TextStyle(
          fontSize: (fSize),
        ),
        labelSmall: TextStyle(
          fontSize: (fSize),
          color: Colors.black54,
        ),
        titleLarge: TextStyle(
          fontSize: (fSize + 10),
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.light(
        background: Colors.white70,
        primary: kSmartQGreen,
        onPrimary: Colors.white,
        primaryContainer: kSmartQGreenLight,
        onPrimaryContainer: kSmartQGreen,
        secondary: Colors.white,
        secondaryContainer: Colors.grey[200],
        tertiaryContainer: kSmartQGreenLight,
        onTertiaryContainer: kSmartQGreen,
      ),
      sliderTheme: const SliderThemeData(
        inactiveTrackColor: Colors.black26,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: kSmartQGreenLight,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? kSmartQGreen : Colors.grey,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              color: states.contains(WidgetState.selected) ? kSmartQGreen : Colors.grey,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );

ThemeData darkMode(double fSize) => ThemeData(
      brightness: Brightness.dark,
      dialogBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: (fSize + 20),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: (fSize),
        ),
        titleMedium: TextStyle(
          fontSize: (fSize),
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontSize: (fSize),
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: (fSize),
        ),
        labelSmall: TextStyle(
          fontSize: (fSize),
          color: Colors.white38,
        ),
        titleLarge: TextStyle(
          fontSize: (fSize + 10),
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.dark(
        background: Colors.black,
        primary: kSmartQGreen,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF14401F),
        onPrimaryContainer: kSmartQGreenLight,
        secondary: Colors.white38,
        secondaryContainer: Colors.grey[500],
        tertiaryContainer: const Color(0xFF14401F),
        onTertiaryContainer: kSmartQGreenLight,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFF14401F),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? kSmartQGreenLight : Colors.white38,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              color: states.contains(WidgetState.selected) ? kSmartQGreenLight : Colors.white38,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );

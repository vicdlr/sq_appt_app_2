
import 'package:flutter/material.dart';

class Styles {

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: isDarkTheme ? Colors.black : Colors.white,

      indicatorColor: isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
      // buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),

      hintColor: isDarkTheme ? const Color(0xff280C0B) : const Color(0xffEECED3),

      highlightColor: isDarkTheme ? const Color(0xff372901) : const Color(0xffFCE192),
      hoverColor: isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xff4285F4),

      focusColor: isDarkTheme ? const Color(0xff0B2512) : const Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? const ColorScheme.dark() : const ColorScheme.light()),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
      ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(background: isDarkTheme ? Colors.black : const Color(0xffF1F5FB)), textSelectionTheme: TextSelectionThemeData(selectionColor: isDarkTheme ? Colors.white : Colors.black),
    );

  }
}
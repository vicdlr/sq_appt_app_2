import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sq_notification/Model/UserDataModel.dart';

class SharedPref {
  static const THEME_STATUS = "THEMESTATUS";
  static const fontSize = "fontSize";
  static const userData = "userData";
  static const authToken = "authToken";
  static const fcmToken = "fcmToken";

  static late SharedPreferences _prefs;
  static const String _userKey = 'user';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static setDarkTheme(bool value)  {
    _prefs.setBool(THEME_STATUS, value);
  }

  static setFonts(double value)  {
    _prefs.setDouble(fontSize, value);
  }

  static getFonts()  {
    return _prefs.getDouble(fontSize) ?? 14.0;
  }

  static getTheme()  {
    return _prefs.getBool(THEME_STATUS) ?? false;
  }


  static setUserData(UserData data){

    final profileJson = jsonEncode(data.toJson());
    return _prefs.setString(userData, profileJson);
  }

 static UserData getUserData(){
    final val = _prefs.getString(userData);
    final profileJson = jsonDecode(val ?? "");
    return  UserData.fromJson(profileJson);
  }

  static setAuthToken(String t){
    _prefs.setString(authToken, t);
  }

  static String? getAuthToken( ){
   return _prefs.getString(authToken);
  }

   static String? getFcmToken( ){
   return _prefs.getString(fcmToken);
  }

  static setFcmToken(String t){
    _prefs.setString(fcmToken, t);
  }

  static deleteData(){
    _prefs.clear();
  }

}
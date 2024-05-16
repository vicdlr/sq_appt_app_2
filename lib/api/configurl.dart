// Your JSON response
// String startTimeString = "2024-01-30T08:41:00.000Z";
// String endTimeString = "2024-01-30T09:41:00.000Z";

// @override
// Widget build(BuildContext context) {
//   DateTime currentTime = DateTime.now();
//   DateTime startTime = DateTime.parse(startTimeString);
//   int minutesLeft = startTime.difference(currentTime).inMinutes;

abstract class ConfigUrl {
  static String baseUrl = "https://node-app-server.onrender.com";
  static String loginUrl = "/login";
  static String signUpUrl = "/register";
  static String updateUrl = "/update";
  static String creatBookingUrl = "/create-booking";
  static String getBookingUrl = "/bookings/user/";
  static String deleteBookingUrl = "/bookings/";
  static String getCityurl = "/get-cities";
  static String updateProfile = "/profile";
  static String notificationUrl = "/notifications/user";
}

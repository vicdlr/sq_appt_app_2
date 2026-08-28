// Your JSON response
// String startTimeString = "2024-01-30T08:41:00.000Z";
// String endTimeString = "2024-01-30T09:41:00.000Z";

// @override
// Widget build(BuildContext context) {
//   DateTime currentTime = DateTime.now();
//   DateTime startTime = DateTime.parse(startTimeString);
//   int minutesLeft = startTime.difference(currentTime).inMinutes;

abstract class ConfigUrl {
  // https://node-app-server.onrender.com/
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
  static String getBadgeTokenUrl = "/badge-token";
  static String updateFcmTokenUrl = "/update-fcm-token";
  static String queueAccessUrl(String bookingId) =>
      "/bookings/$bookingId/queue-access";
  static String manageBookingsLinkUrl = "/careconnect/manage-bookings-link";
  // Mints a token-bridged SSO link into ccadmin (STAFF session), same pattern as
  // manageBookingsLinkUrl above but for Service Provider Mode -- see service_provider_mode.dart.
  static String serviceProviderLinkUrl = "/careconnect/service-provider-link";

  // CareConnect's ccadmin pages -- opened via serviceProviderLinkUrl's token-bridged SSO link
  // (2026-08-19), not directly, so Service Provider Mode never hits ccadmin's own login wall.
  static String careConnectAdminBaseUrl = "https://ccadmin.smartqsys.com";

  static String deleteUserUrl(String userId) => "/users/$userId";
  static String forgotPasswordUrl = "/forgot-password";

  // Mints a token-bridged SSO link into CareConnect's own "More" page (PATIENT session) -- the
  // bottom-nav "More" tab's destination (2026-08-28), see bottom_nav_bar.dart's _openMore.
  static String moreLinkUrl = "/careconnect/more-link";
}

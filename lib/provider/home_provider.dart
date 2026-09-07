import 'dart:io';

import 'package:dio/dio.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/Model/BookingModel.dart';
import 'package:sq_notification/Model/IndustryModel.dart';
import 'package:sq_notification/Model/NotificationModel.dart';
import 'package:sq_notification/Model/OrganizationModel.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';

import '../Model/ServiceOptionModel.dart';
import '../Model/UnitModel.dart';
import '../view/home/bottom_nav_bar.dart';
import '../view/home/get_ticket.dart';

class HomeProvider extends ChangeNotifier {
  String selectedIndusty = "";
  String selectedCompanies = "";
  String selectedUnit = "";
  String serviceType = "Service type";
  // "AUTO" | "MANUAL" | null -- null means either not yet fetched or this unit isn't a
  // CareConnect-managed one at all (legacy Site-routed booking). Only ever meaningful for
  // deciding whether createBooking() can land the client straight in Manage Bookings afterward
  // (2026-09-07, per the user) -- never shown in the UI itself.
  String? confirmMode;

  int selectedIndex = 0;
  bool isLoading = false;

  List<String> industryList = [];
  List<IndustryModel> industryDataList = [];

  List<String> companiesList = [];
  List<OrganizationModel> companiesDataList = [];

  List<String> unitList = [];
  List<UnitModel> unitDataList = [];

  List<BookingModel> bookingList = [];
  List<NotificationModel> notificationList = [];
  List<ServiceOptionModel> serviceOptions = [];

  Future<void> getIndustriesList() async {
    final result = await DioApi.get(
        path: "/industries?city=${SharedPref.getUserData().city}");

    if (result.response?.statusCode != null) {
      industryDataList = (result.response?.data["industries"] as List<dynamic>)
          .map((data) => IndustryModel.fromJson(data))
          .toList();
      industryList = industryDataList.map((data) => data.industry).toList();
      notifyListeners();
    } else {}
  }

  void changeSelectedIndex(int val) {
    selectedIndex = val;
    notifyListeners();
  }

  void setSelectedList(String value) {
    print("value $value");
    selectedIndusty = value;
    selectedCompanies = "";
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
    getCompaniesList();
  }

  Future<void> getCompaniesList() async {
    final result = await DioApi.get(
        path:
            "/organisations?city=${SharedPref.getUserData().city}&industry=$selectedIndusty");

    if (result.response?.statusCode != null) {
      companiesDataList =
          (result.response?.data["organisations"] as List<dynamic>)
              .map((data) => OrganizationModel.fromJson(data))
              .toList();
      companiesList = companiesDataList
          .map(
            (data) => data.company,
          )
          .toList();
      notifyListeners();
    } else {}
  }

  Future<void> setCompaniesList(String value) async {
    print("value $value");
    selectedCompanies = value;
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
    await getUnitList();
  }

  // "Choose Service Provider" in the simplified 3-step booking flow (Industry -> Organisation ->
  // Service Provider) -- this is the same underlying `unit` concept as before, Department/Group
  // were an intermediate drill-down that's no longer part of the flow. /units already treats
  // department/groupname as optional filters server-side, so omitting them here just returns
  // every unit under the selected industry/organisation instead of a narrower subset.
  Future<void> getUnitList() async {
    final result = await DioApi.get(
        path: "/units?city=${SharedPref.getUserData().city}"
            "&company=$selectedCompanies&industry=$selectedIndusty");

    if (result.response?.statusCode != null) {
      unitDataList = (result.response?.data["filteredData"] as List<dynamic>)
          .map((data) => UnitModel.fromJson(data))
          .toList();
      unitList = unitDataList.map((data) => data.unit).toList();
      notifyListeners();
    } else {}
  }

  void setUnitList(String value) {
    print("value $value");
    selectedUnit = value;
    confirmMode = null;
    for (var unitData in unitDataList) {
      if (unitData.unit.toLowerCase() == value.toLowerCase()) {
        serviceType = unitData.servicetype;
      }
    }
    fetchConfirmMode(value);

    notifyListeners();
  }

  // Best-effort -- a failed/absent lookup just means createBooking() falls back to today's plain
  // toast+Home behavior, same as a genuinely MANUAL unit. Fire-and-forget from setUnitList rather
  // than awaited there, so picking a unit never blocks on this network call.
  Future<void> fetchConfirmMode(String unit) async {
    final result = await DioApi.get(path: ConfigUrl.confirmModeUrl(unit));
    if (result.response?.data?["success"] == true) {
      confirmMode = result.response?.data?["data"]?["confirmMode"];
    } else {
      confirmMode = null;
    }
    notifyListeners();
  }

  Future<void> createBooking(
    BuildContext context, {
    String? date,
    String? startTime,
    String? endTime,
    File? file,
    String? companyName,
    String? deliveryPerson,
    String? remarks,
  }) async {
    isLoading = true;
    notifyListeners();

    var data = FormData.fromMap({
      'user_id': SharedPref.getUserData().id,
      'user_name': SharedPref.getUserData().username,
      'industry': selectedIndusty,
      'organisation': selectedCompanies,
      'customerid': SharedPref.getUserData().customerId,
      if (file != null)
        'image': [
          await MultipartFile.fromFile(
            file.path.toString(),
            filename: file.path.toString(),
          )
        ],
      if (date != null) 'booking_date': date,
      'unit': selectedUnit,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      'city': SharedPref.getUserData().city,
      'email': SharedPref.getUserData().email,
      'company_name': companyName,
      'delivery_person_name': deliveryPerson,
      'remarks': remarks,
      "servicetype": serviceType
    });

    print("formdata ${data.fields}");

    final result =
        await DioApi.post(path: ConfigUrl.creatBookingUrl, data: data);

    if (result.response != null) {
      isLoading = false;
      notifyListeners();
      await Fluttertoast.showToast(msg: "Successfully created booking");
      setIndustriesEmpty();

      final newBookingId = result.response?.data?["bookingData"]?["id"];
      if (confirmMode == "AUTO" && newBookingId != null && context.mounted) {
        final opened = await _openIfAutoConfirmed(context, newBookingId.toString());
        if (opened) return;
      }

      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return BottomNavBar();
      }), (route) => false);
    } else {
      isLoading = false;
      notifyListeners();
      result.handleError(context);
    }
  }

  // AUTO-confirm bookings -> land the client straight in Manage Bookings, focused, Support Hub
  // included, instead of the plain toast+Home (2026-09-07, per the user, "one continuous flow").
  // /create-booking fires the actual CareConnect confirmation asynchronously (deliberately, so a
  // slow/down CareConnect never blocks booking creation) -- polls this device's own booking list
  // for handled_by to flip to "CARECONNECT" before minting the queue-access token, since NAS's
  // own /bookings/:bookingId/queue-access hard-requires that first. Returns false (falls back to
  // the caller's plain toast+Home) on any failure -- nothing about the booking itself is at risk
  // either way, this only affects where the client lands afterward.
  Future<bool> _openIfAutoConfirmed(BuildContext context, String bookingId) async {
    const pollInterval = Duration(seconds: 1);
    const maxAttempts = 8;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await DioApi.get(
        path: ConfigUrl.getBookingUrl + SharedPref.getUserData().id,
      );
      final bookings = result.response?.data?["bookings"] as List<dynamic>?;
      final match = bookings?.firstWhere(
        (b) => b["id"].toString() == bookingId,
        orElse: () => null,
      );
      if (match != null && match["handled_by"] == "CARECONNECT") break;
      if (attempt == maxAttempts - 1) return false;
      await Future.delayed(pollInterval);
    }

    final access = await DioApi.post(
      path: ConfigUrl.queueAccessUrl(bookingId),
      data: {"dest": "bookings"},
    );
    final careConnectUrl = access.response?.data?["data"]?["careConnectUrl"];
    if (access.response == null || careConnectUrl == null) return false;

    if (!context.mounted) return false;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        return WebViewPage(url: careConnectUrl, title: 'Manage Bookings');
      }),
      (route) => false,
    );
    return true;
  }

  // Tapping a patient-facing booking notification (confirmed/checked-in/processing/your turn --
  // 2026-09-07, per the user) -- same queue-access bridge as the "View Status" card and the
  // auto-confirm flow above, just without the poll loop (the booking is already in whatever state
  // the notification is reporting by the time it's tapped). Pushes on top of wherever the app
  // currently is, same convention _ActiveQueueCard._viewStatus() already uses.
  Future<void> openPatientBookingFromNotification(BuildContext context, String externalBookingId) async {
    final access = await DioApi.post(
      path: ConfigUrl.queueAccessUrl(externalBookingId),
      data: {"dest": "bookings"},
    );
    final careConnectUrl = access.response?.data?["data"]?["careConnectUrl"];
    if (access.response == null || careConnectUrl == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WebViewPage(url: careConnectUrl, title: 'Booking');
    }));
  }

  // Staff-side sibling of the above -- tapping a "new booking"/"support ticket" notification
  // (2026-09-07, per the user) opens ccadmin/servadmin's Appointments page focused on that exact
  // booking, via the same Service Provider Mode SSO bridge service_provider_mode.dart already
  // uses, just with a focusBookingId this time. bookingId here is CareConnect's own uuid (what
  // these two notification types already carry in their `data`), not NAS's numeric id -- a
  // different id-space than openPatientBookingFromNotification above.
  Future<void> openStaffBookingFromNotification(BuildContext context, String bookingId) async {
    final result = await DioApi.post(
      path: ConfigUrl.serviceProviderLinkUrl,
      data: {"next": "bookings", "focusBookingId": bookingId},
    );
    final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
    if (result.response == null || careConnectUrl == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WebViewPage(url: careConnectUrl, title: 'Appointments');
    }));
  }

  setIndustriesEmpty() {
    selectedIndusty = "";
    selectedCompanies = "";
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
  }

  bool isLoadingBooking = false;

  Future<void> getAllBooking(
    BuildContext context,
  ) async {
    isLoadingBooking = true;
    notifyListeners();
    final result = await DioApi.get(
      path: (ConfigUrl.getBookingUrl + SharedPref.getUserData().id),
    );

    if (result.response != null) {
      bookingList = (result.response?.data["bookings"] as List<dynamic>)
          .map((data) => BookingModel.fromJson(data))
          .toList();
      // bookingList.sort((a, b) {
      //   return b.bookingDate!.compareTo(a.bookingDate!);
      // });
      isLoadingBooking = false;
      notifyListeners();
    } else {
      isLoadingBooking = false;
      notifyListeners();
      result.handleError(context);
    }
  }

  Future<void> deleteBooking(BuildContext context, String id) async {
    /*final result = await DioApi.delete(
      path: (ConfigUrl.deleteBookingUrl + id),
    );*/
    final result = await DioApi.get(
      path: (ConfigUrl.deleteBookingUrl + id),
    );

    if (result.response != null) {
      await Fluttertoast.showToast(msg: "Request to cancel booking submitted");
      getAllBooking(context);
    } else {
      result.handleError(context);
    }
  }

  Future<void> getNotificationList(
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();
    final result = await DioApi.get(path: ConfigUrl.notificationUrl);

    if (result.response != null) {
      notificationList =
          (result.response?.data["notifications"] as List<dynamic>)
              .map((data) => NotificationModel.fromJson(data))
              .toList();

      notificationList.sort((a, b) {
        return b.sentTime!.compareTo(a.sentTime!);
      });

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
      result.handleError(context);
    }
  }


  // get the servotpions and notes
  Future<void> getServiceOptions(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final result = await DioApi.post(path: "/service-options", data: {
      "industry": selectedIndusty,
      "city": SharedPref.getUserData().city,
      "company": selectedCompanies,
      "servicetype": serviceType,
      "unit": selectedUnit,
      // Server requires these keys to be present even though the simplified booking flow no
      // longer has a department/group drill-down step -- empty string matches its own
      // department = '' / groupname = '' fallback filter.
      "department": "",
      "groupname": "",
    });

    if (result.response != null) {
      try {
        serviceOptions = (result.response?.data["data"] as List<dynamic>)
            .map((data) => ServiceOptionModel.fromJson(data))
            .toList();

        notifyListeners();
      } catch (e) {
        Fluttertoast.showToast(msg: "Something went wrong. Please try again.");
      }
    } else {
      result.handleError(context); // Graceful error message fallback
    }

    isLoading = false;
    notifyListeners();
  }
}

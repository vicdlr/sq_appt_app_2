import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/Model/BookingModel.dart';
import 'package:sq_notification/Model/IndustryModel.dart';
import 'package:sq_notification/Model/NotificationModel.dart';
import 'package:sq_notification/Model/OrganizationModel.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';

import '../Model/DepartmentModel.dart';
import '../Model/GroupModel.dart';
import '../Model/UnitModel.dart';
import '../view/home/bottom_nav_bar.dart';

class HomeProvider extends ChangeNotifier {
  String selectedIndusty = "";
  String selectedCompanies = "";
  String selectedDepartment = "";
  String selectedGroup = "";
  String selectedUnit = "";
  String serviceType = "Service type";

  int selectedIndex = 0;
  bool isLoading = false;

  List<DropDownValueModel> industryList = [];
  List<IndustryModel> industryDataList = [];

  List<DropDownValueModel> companiesList = [];
  List<OrganizationModel> companiesDataList = [];

  List<DropDownValueModel> departmentList = [];
  List<DepartmentModel> departmentDataList = [];

  List<DropDownValueModel> groupList = [];
  List<GroupModel> groupDataList = [];

  List<DropDownValueModel> unitList = [];
  List<UnitModel> unitDataList = [];

  List<BookingModel> bookingList = [];
  List<NotificationModel> notificationList = [];

  Future<void> getIndustriesList() async {
    final result = await DioApi.get(
        path: "/industries?city=${SharedPref.getUserData().city}");

    if (result.response?.statusCode != null) {
      industryDataList = (result.response?.data["industries"] as List<dynamic>)
          .map((data) => IndustryModel.fromJson(data))
          .toList();
      industryList = industryDataList
          .map((data) =>
              DropDownValueModel(name: data.industry, value: data.code))
          .toList();
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
    selectedDepartment = "";
    selectedGroup = "";
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
          .map((data) =>
              DropDownValueModel(name: data.company, value: data.code))
          .toList();
      notifyListeners();
    } else {}
  }

  void setCompaniesList(String value) {
    print("value $value");
    selectedCompanies = value;
    selectedDepartment = "";
    selectedGroup = "";
    selectedUnit = "";
    serviceType = "Service type";
    getDepartmentList();
    notifyListeners();
  }

  Future<void> getDepartmentList() async {
    final result = await DioApi.get(
        path:
            "/departments?city=${SharedPref.getUserData().city}&industry=$selectedIndusty&company=$selectedCompanies");

    if (result.response?.statusCode != null) {
      departmentDataList =
          (result.response?.data["departments"] as List<dynamic>)
              .map((data) => DepartmentModel.fromJson(data))
              .toList();
      departmentList = departmentDataList
          .map((data) =>
              DropDownValueModel(name: data.department, value: data.code))
          .toList();
      notifyListeners();
    } else {}
  }

  void setDepartmentList(String value) {
    print("value $value");
    selectedDepartment = value;
    selectedGroup = "";
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
    getGroupList();
  }

  Future<void> getGroupList() async {
    final result = await DioApi.get(
      path: "/groupfiles?city=${SharedPref.getUserData().city}"
          "&company=$selectedCompanies&industry=$selectedIndusty"
          "&department=$selectedDepartment",
    );

    if (result.response?.statusCode != null) {
      groupDataList = (result.response?.data["filteredData"] as List<dynamic>)
          .map((data) => GroupModel.fromJson(data))
          .toList();
      groupList = groupDataList
          .map((data) =>
              DropDownValueModel(name: data.groupname, value: data.code))
          .toList();
      notifyListeners();
    } else {}
  }

  void setGroupList(String value) {
    print("value $value");
    selectedGroup = value;
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
    getUnitList();
  }

  Future<void> getUnitList() async {
    final result = await DioApi.get(
        path: "/units?city=${SharedPref.getUserData().city}"
            "&company=$selectedCompanies&industry=$selectedIndusty"
            "&department=$selectedDepartment&groupname=$selectedGroup");

    if (result.response?.statusCode != null) {
      unitDataList = (result.response?.data["filteredData"] as List<dynamic>)
          .map((data) => UnitModel.fromJson(data))
          .toList();
      unitList = unitDataList
          .map(
            (data) => DropDownValueModel(
              name: data.unit,
              value: data.code,
            ),
          )
          .toList();
      notifyListeners();
    } else {}
  }

  void setUnitList(String value) {
    print("value $value");
    selectedUnit = value;
    for (var unitData in unitDataList) {
      if (unitData.unit.toLowerCase() == value.toLowerCase()) {
        serviceType = unitData.servicetype;
      }
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
      'department': selectedDepartment,
      'groups': selectedGroup,
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

  setIndustriesEmpty() {
    selectedIndusty = "";
    selectedCompanies = "";
    selectedDepartment = "";
    selectedGroup = "";
    selectedUnit = "";
    serviceType = "Service type";
    notifyListeners();
  }

  Future<void> getAllBooking(
    BuildContext context,
  ) async {
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
      notifyListeners();
    } else {
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
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      notificationList = notificationList.where((notification) {
        return notification.sentTime?.month == currentMonth &&
            notification.sentTime?.year == currentYear;
      }).toList();

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
}

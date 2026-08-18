import 'dart:async';
import 'dart:io';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant/dailog.dart';
import 'configurl.dart';

class DioConfig {
  // Kill-switch flags mirrored from every API response's force_update_android/force_update_ios
  // fields (see node_app_server's auth.js). Cached here rather than acted on immediately -- an
  // undismissable dialog firing off whatever random background API call happens to return first
  // would interrupt users mid-task; callers instead check this at deliberate re-entry points
  // (New Booking, Manage Bookings) via maybeBlockForForceUpdate, so a long-lived app session that
  // never restarts still gets gated at the moments that actually matter.
  static bool forceUpdateAndroid = false;
  static bool forceUpdateIos = false;

  static BaseOptions options = BaseOptions(
    baseUrl: ConfigUrl.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    receiveDataWhenStatusError: true,
  );
  static final Dio _dio = Dio(options)
    ..interceptors.add(PrettyDioLogger())
    ..interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) async {
        if (response.data is Map) {
          _cacheForceUpdateFlags(response.data);
        }
        handler.next(response);
      },
    ));

  static get dio => _dio;

  static void _cacheForceUpdateFlags(Map<String, dynamic> responseData) {
    forceUpdateAndroid = responseData["force_update_android"] == true;
    forceUpdateIos = responseData["force_update_ios"] == true;
  }

  // Returns true (and shows the blocking dialog) if the app must be updated before proceeding.
  // Call this at the start of a flow, before letting it continue.
  static bool maybeBlockForForceUpdate(BuildContext context) {
    final required = Platform.isAndroid
        ? forceUpdateAndroid
        : Platform.isIOS
            ? forceUpdateIos
            : false;
    if (!required) return false;

    final updateUrl = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=com.smartqsys.sq_notification"
        : "https://apps.apple.com/us/app/sq-appt-app/id6499111118";
    _showForceUpdateDialog(context, updateUrl);
    return true;
  }

  static void _showForceUpdateDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Update Required"),
        content: const Text("A new version is required. Please update the app."),
        actions: [
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text("Update Now"),
          ),
        ],
      ),
    );
  }
}




class Result {
  Response? response;
  DioException? dioError;

  Result({this.response, this.dioError});

  void handleError(BuildContext context) {
    if (dioError != null) {
      final error = dioError!.error;
      // log("response realUri ==  ${response?.data}");
      if (error is SocketException) {
        Dialogs.errorDialog(
            context, 'Failed to connect to sq servers.');
      } else if (error is TimeoutException) {
        Dialogs.errorDialog(context, 'Request timed out. Try again.');
      } else if (dioError!.response != null &&
          dioError!.response!.data is Map) {
        final errMsg = dioError!.response?.data["message"];

        // log("ERR MSG: $errMsg");

        if (errMsg != null) {
          Dialogs.errorDialog(context, '$errMsg');
        } else if (dioError?.response?.statusCode == 404) {
          final errMsg = dioError!.response?.data;
          Dialogs.errorDialog(context, '$errMsg');
        } else {
          // ignore: use_build_context_synchronously
          Dialogs.errorDialog(context, 'There was a problem. Try again.');
        }
      }
      else if (dioError!.response != null){
        final errMsg = dioError!.response?.data;
        Dialogs.errorDialog(context, errMsg);
      }
    }
  }
}

class DioErrorWithMessage implements Exception {
  DioException dioError;
  String errorMessage;

  DioErrorWithMessage(this.dioError, this.errorMessage);
  static DioErrorWithMessage showException({required Result result}) {
    if (result.dioError?.error is SocketException) {
      throw DioErrorWithMessage(
          result.dioError!, ExceptionErrorString.socketErrorMessage);
    } else if (result.dioError?.error is TimeoutException) {
      throw DioErrorWithMessage(
          result.dioError!, ExceptionErrorString.timeOutErrorMessage);
    } else if (result.dioError!.response != null &&
        result.dioError!.response!.data is Map) {
      final errMsg = result.dioError!.response?.data['error'];
      throw DioErrorWithMessage(result.dioError!, errMsg);

    } else if (result.dioError?.response?.statusCode == 404) {
      throw DioErrorWithMessage(
          result.dioError!, ExceptionErrorString.notFoundErrorMessage);
    } else {
      throw Exception('There was a problem. Try again.');
    }
  }
}

class ExceptionErrorString {
  static const socketErrorMessage =
      'Failed to connect to Guru coaching centre servers.';
  static const timeOutErrorMessage = 'Request timed out. Try again.';
  static const notFoundErrorMessage = 'Resource not found';
}

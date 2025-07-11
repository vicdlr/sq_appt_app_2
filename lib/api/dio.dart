import 'dart:async';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant/dailog.dart';
import 'configurl.dart';

import 'package:sq_notification/main.dart'; // import where navigatorKey is defined


class DioConfig {


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
        // Check for version info in API response
        if (response.data is Map) {
          await _checkForUpdate(response.data);
          }
          handler.next(response);
          },
    ));

  static get dio => _dio;

  static Future<void> _checkForUpdate(Map<String, dynamic> responseData) async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get minimum required version from API response
      String? minimumVersion;
      if (Platform.isAndroid && responseData.containsKey("minimum_version_android")) {
        minimumVersion = responseData["minimum_version_android"];
      } else if (Platform.isIOS && responseData.containsKey("minimum_version_ios")) {
        minimumVersion = responseData["minimum_version_ios"];
      }
      // If minimum version is not provided, skip check
      if (minimumVersion == null || minimumVersion.isEmpty) return;
      // Compare versions
      if (_isUpdateRequired(currentVersion, minimumVersion)) {
        String updateUrl = "";
        final updateMessage = "A new version is required. Please update the app.";

        if (Platform.isAndroid) {
          updateUrl = "https://play.google.com/store/apps/details?id=com.smartqsys.sq_notification";
        } else if (Platform.isIOS) {
          updateUrl = "https://apps.apple.com/us/app/sq-appt-app/id6499111118";
        }

        BuildContext? context = navigatorKey.currentContext;
        _showForceUpdateDialog(context, updateMessage, updateUrl);
      }
    } catch (e) {
      // Handle any errors in version checking silently
      print('Version check error: $e');
    }
  }

  static bool _isUpdateRequired(String currentVersion, String minimumVersion) {
    // Parse version strings (assuming format like "1.2.3")
    List<int> current = _parseVersion(currentVersion);
    List<int> minimum = _parseVersion(minimumVersion);

    // Compare version numbers
    for (int i = 0; i < 3; i++) {
      if (current[i] < minimum[i]) {
        return true; // Update required
      } else if (current[i] > minimum[i]) {
        return false; // Current version is higher
      }
      // If equal, continue to next part
    }

    return false; // Versions are equal, no update required
  }

  static List<int> _parseVersion(String version) {
    // Remove any non-numeric characters except dots
    String cleanVersion = version.replaceAll(RegExp(r'[^\d\.]'), '');

    // Split by dots and convert to integers
    List<String> parts = cleanVersion.split('.');
    List<int> versionParts = [];

    // Ensure we have at least 3 parts (major.minor.patch)
    for (int i = 0; i < 3; i++) {
      if (i < parts.length && parts[i].isNotEmpty) {
        versionParts.add(int.tryParse(parts[i]) ?? 0);
      } else {
        versionParts.add(0);
      }
    }

    return versionParts;
  }

  static void _showForceUpdateDialog(BuildContext? context, String message, String url) {
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Update Required"),
        content: Text(message),
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

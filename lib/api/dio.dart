import 'dart:async';
import 'dart:io';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constant/dailog.dart';
import 'configurl.dart';



class DioConfig {
  static BaseOptions options = BaseOptions(
    baseUrl: ConfigUrl.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    receiveDataWhenStatusError: true,
  );

  static final Dio _dio = Dio(options)..interceptors.add(PrettyDioLogger());

  static get dio => _dio;
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
        final errMsg = dioError!.response?.data;

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

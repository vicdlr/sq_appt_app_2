
import 'package:dio/dio.dart';


import '../SharedPrefrence/SharedPrefrence.dart';
import 'dio.dart';

class DioApi {
  static Future<Result> post(
      {required String path,
      required dynamic data,
      Duration? sendTimeout,
      Duration? recvTimeout}) async {
    final token = SharedPref.getAuthToken();
    try {
      Response response = await DioConfig.dio.request(
        path,
        data: data,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: recvTimeout,
          headers: {
            "x-access-token": token,
          },
          method: 'POST',
        ),
      );
      DioException? err;
      return Result(response: response, dioError: err);
    } on DioException catch (e) {
      Response? response;
      // log("response ${e.response?.data["message"]}");
      return Result(response: response, dioError: e);
    }
  }

  static Future<Result> get(
      {required String path,
      dynamic data,
      Duration? sendTimeout,
      Duration? recvTimeout}) async {
    final token = SharedPref.getAuthToken();
    try {
      Response response = await DioConfig.dio.request(
        path,
        data: data,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: recvTimeout,
          headers: {"x-access-token": token},
          method: 'GET',
        ),
      );
      DioException? err;
      return Result(response: response, dioError: err);
    } on DioException catch (e) {
      Response? response;
      return Result(response: response, dioError: e);
    }
  }

  static Future<Result> delete(
      {required String path,
      Duration? sendTimeout,
      Duration? recvTimeout}) async {
    final token = SharedPref.getAuthToken();
    // log(token);
    try {
      Response response = await DioConfig.dio.request(
        path,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: recvTimeout,
          headers: {"x-access-token": token},
          method: 'DELETE',
        ),
      );
      DioException? err;
      return Result(response: response, dioError: err);
    } on DioException catch (e) {
      Response? response;
      return Result(response: response, dioError: e);
    }
  }

  static Future<Result> put(
      {required String path,
      dynamic data,
      Duration? sendTimeout,
      Duration? recvTimeout}) async {
    final token = SharedPref.getAuthToken();
    try {
      Response response = await DioConfig.dio.request(
        path,
        data: data,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: recvTimeout,
          headers: {"x-access-token": token},
          method: 'PUT',
        ),
      );
      DioException? err;
      return Result(response: response, dioError: err);
    } on DioException catch (e) {
      Response? response;
      return Result(response: response, dioError: e);
    }
  }

  static Future<Result> patch(
      {required String path,
      Duration? sendTimeout,
      Duration? recvTimeout}) async {
    final token = SharedPref.getAuthToken();
    // log(token);
    try {
      Response response = await DioConfig.dio.request(
        path,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: recvTimeout,
          headers: {"x-access-token": token},
          method: 'PATCH',
        ),
      );
      DioException? err;
      return Result(response: response, dioError: err);
    } on DioException catch (e) {
      Response? response;
      return Result(response: response, dioError: e);
    }
  }
}

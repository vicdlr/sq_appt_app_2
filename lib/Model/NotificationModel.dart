class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.fcmToken,
    required this.data,
    required this.response,
    required this.requestTime,
    required this.sentTime,
    required this.status,
  });

  final int id;
  final int userId;
  final String title;
  final String message;
  final String fcmToken;
  final Data? data;
  final String response;
  final DateTime? requestTime;
  final DateTime? sentTime;
  final String status;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      fcmToken: json["fcm_token"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      response: json["response"] ?? "",
      requestTime: DateTime.tryParse(json["request_time"] ?? ""),
      sentTime: DateTime.tryParse(json["sent_time"] ?? ""),
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "message": message,
        "fcm_token": fcmToken,
        "data": data?.toJson(),
        "response": response,
        "request_time": requestTime?.toIso8601String(),
        "sent_time": sentTime?.toIso8601String(),
        "status": status,
      };

  @override
  String toString() {
    return "$id, $userId, $title, $message, $fcmToken, $data, $response, $requestTime, $sentTime, $status, ";
  }
}

class Data {
  Data({required this.json});
  final Map<String, dynamic> json;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(json: json);
  }

  Map<String, dynamic> toJson() => {};

  @override
  String toString() {
    return "";
  }
}

/*
{
	"id": 2,
	"user_id": 59,
	"title": "Origin",
	"message": "Biosphere Exists",
	"fcm_token": "eKye5p9LR-Sg2Ltno8o2-d:APA91bGbBqZvANmwBR9gXseHkn3KMYjFvVdUDDV4UOoyJ5-5o6daUS-p-luZQGvNT6rO7STBV2HTB6S91bwnOTsEdaSFmfJ4wdmVjyMsZcukm9TatJa_AEZ_GEIjA8DmRAK4uziIw0gE",
	"data": {},
	"response": "projects/sqnotification/messages/0:1711798443641356%8f1f29168f1f2916",
	"request_time": "2024-03-30T17:04:03.305Z",
	"sent_time": "2024-03-30T17:04:03.692Z",
	"status": "Success"
}*/
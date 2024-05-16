class BookingModel {
  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.industry,
    required this.organisation,
    required this.department,
    required this.groups,
    required this.unit,
    required this.bookingDate,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.apptTime,
    required this.status,
    required this.email,
    required this.city,
    required this.companyName,
    required this.deliveryPersonName,
    required this.remarks,
    required this.servicetype,
  });

  final int id;
  final int userId;
  final String userName;
  final String industry;
  final String organisation;
  final String department;
  final String groups;
  final String unit;
  final DateTime? bookingDate;
  final String imageUrl;
  final dynamic startTime;
  final dynamic endTime;
  final dynamic apptTime;
  final String status;
  final dynamic email;
  final dynamic city;
  final dynamic companyName;
  final dynamic deliveryPersonName;
  final dynamic remarks;
  final dynamic servicetype;

  factory BookingModel.fromJson(Map<String, dynamic> json){
    return BookingModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      userName: json["user_name"] ?? "",
      industry: json["industry"] ?? "",
      organisation: json["organisation"] ?? "",
      department: json["department"] ?? "",
      groups: json["groups"] ?? "",
      unit: json["unit"] ?? "",
      bookingDate: DateTime.tryParse(json["booking_date"] ?? ""),
      imageUrl: json["image_url"] ?? "",
      startTime: json["start_time"],
      endTime: json["end_time"],
      apptTime: json["appt_time"],
      status: json["status"] ?? "",
      email: json["email"],
      city: json["city"],
      companyName: json["company_name"],
      deliveryPersonName: json["delivery_person_name"],
      remarks: json["remarks"],
      servicetype: json["servicetype"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "user_name": userName,
    "industry": industry,
    "organisation": organisation,
    "department": department,
    "groups": groups,
    "unit": unit,
    "booking_date": bookingDate?.toIso8601String(),
    "image_url": imageUrl,
    "start_time": startTime,
    "end_time": endTime,
    "appt_time": apptTime,
    "status": status,
    "email": email,
    "city": city,
    "company_name": companyName,
    "delivery_person_name": deliveryPersonName,
    "remarks": remarks,
    "servicetype": servicetype,
  };

  @override
  String toString(){
    return "$id, $userId, $userName, $industry, $organisation, $department, $groups, $unit, $bookingDate, $imageUrl, $startTime, $endTime, $apptTime, $status, $email, $city, $companyName, $deliveryPersonName, $remarks, $servicetype, ";
  }

}

/*
{
	"id": 9,
	"user_id": 123,
	"user_name": "kaalu",
	"industry": "Technology",
	"organisation": "XYZ Corp",
	"department": "Engineering",
	"groups": "Development Team",
	"unit": "Software Division",
	"booking_date": "2024-03-24T00:00:00.000Z",
	"image_url": "https://res.cloudinary.com/dc8piabne/image/upload/v1711178006/wolxi7hikzhtkxjhgxvv.jpg",
	"start_time": null,
	"end_time": null,
	"status": "Pending",
	"email": null,
	"city": null,
	"company_name": null,
	"delivery_person_name": null,
	"remarks": null,
	"servicetype": null
}*/
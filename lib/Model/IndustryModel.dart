class IndustryModel {
  IndustryModel({
    required this.id,
    required this.industry,
    required this.code,
    required this.city,
  });

  final int id;
  final String industry;
  final dynamic code;
  final String city;

  factory IndustryModel.fromJson(var json) {
    return IndustryModel(
      id: json["id"] ?? 0,
      industry: json["industry"] ?? "",
      code: json["code"] ?? "",
      city: json["city"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "industry": industry,
        "code": code,
        "city": city,
      };

  @override
  String toString() {
    return "$id, $industry, $code, $city";
  }
}
/*
class IndustryModel {
  IndustryModel({
    required this.id,
    required this.industry,
    required this.code,
    required this.city,
  });

  final int id;
  final String industry;
  final dynamic code;
  final String city;

  factory IndustryModel.fromJson(var json) {
    return IndustryModel(
      id: json["id"] ?? 0,
      industry: json["industry"] ?? "",
      code: json["code"],
      city: json["city"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "industry": industry,
        "code": code,
        "city": city,
      };

  @override
  String toString() {
    return "$id, $industry, $code, $city, ";
  }
}
*/

/*
{
	"id": 3,
	"name": "Sp10",
	"age": null,
	"departmentname": "Silver",
	"departmentcode": 144545,
	"city": "Los Angeles"
}*/
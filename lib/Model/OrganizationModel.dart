class OrganizationModel {
  OrganizationModel({
    required this.id,
    required this.company,
    required this.code,
    required this.city,
    required this.industry,
  });

  final int id;
  final String company;
  final dynamic code;
  final String city;
  final String industry;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json["id"] ?? 0,
      company: json["company"] ?? "",
      code: json["code"],
      city: json["city"] ?? "",
      industry: json["industry"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "company": company,
        "code": code,
        "city": city,
        "industry": industry,
      };

  @override
  String toString() {
    return "$id, $company, $code, $city, $industry, ";
  }
}

/*
{
	"id": 4,
	"name": "Sp11",
	"age": null,
	"departmentname": "Health World",
	"departmentcode": 15245,
	"city": "New York",
	"industry": "Social Worker"
}*/
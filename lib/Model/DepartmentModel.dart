class DepartmentModel {
  DepartmentModel({
    required this.id,
    required this.department,
    required this.code,
    required this.city,
    required this.industry,
    required this.company,
  });

  final int id;
  final String department;
  final dynamic code;
  final String city;
  final String industry;
  final String company;

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json["id"] ?? 0,
      department: json["department"] ?? "",
      code: json["code"] ?? 0,
      city: json["city"] ?? "",
      industry: json["industry"] ?? "",
      company: json["company"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "department": department,
        "code": code,
        "city": city,
        "industry": industry,
        "company": company,
      };

  @override
  String toString() {
    return "$id, $department, $code, $city, $industry, $company, ";
  }
}

/*
{
	"id": 1,
	"name": "spr56",
	"age": null,
	"departmentname": "receiving",
	"departmentcode": 12,
	"city": "Metro Manila",
	"industry": "Healthcare",
	"company": "NKTI",
	"department": "Pathology",
	"servicetype": "Data Capture",
	"groupname": "Delivery"
}*/
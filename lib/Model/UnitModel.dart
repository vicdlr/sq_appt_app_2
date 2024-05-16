class UnitModel {
  UnitModel({
    required this.id,
    required this.unit,
    required this.code,
    required this.city,
    required this.industry,
    required this.company,
    required this.department,
    required this.servicetype,
    required this.groupname,
  });

  final int id;
  final String unit;
  final dynamic code;
  final String city;
  final String industry;
  final String company;
  final String department;
  final String servicetype;
  final String groupname;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json["id"] ?? 0,
      unit: json["unit"] ?? "",
      code: json["code"],
      city: json["city"] ?? "",
      industry: json["industry"] ?? "",
      company: json["company"] ?? "",
      department: json["department"],
      servicetype: json["servicetype"] ?? "",
      groupname: json["groupname"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "unit": unit,
        "code": code,
        "city": city,
        "industry": industry,
        "company": company,
        "department": department,
        "servicetype": servicetype,
        "groupname": groupname,
      };

  @override
  String toString() {
    return "$id, $unit, $code, $city, $industry, $company,$department, $servicetype, $groupname, ";
  }
}

/*
{
	"id": 4,
	"name": "Sp1",
	"age": null,
	"departmentname": "Software Department",
	"departmentcode": 14345,
	"city": "Los Angeles",
	"industry": "IT",
	"company": "HCL"
}*/
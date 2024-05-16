class GroupModel {
  GroupModel({
    required this.id,
    required this.groupname,
    required this.code,
    required this.city,
    required this.industry,
    required this.company,
    required this.department,
  });

  final int id;
  final String groupname;
  final dynamic code;
  final String city;
  final String industry;
  final String company;
  final String department;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json["id"] ?? 0,
      groupname: json["groupname"] ?? "",
      code: json["code"],
      city: json["city"] ?? "",
      industry: json["industry"] ?? "",
      company: json["company"] ?? "",
      department: json["department"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "unit": groupname,
        "code": code,
        "city": city,
        "industry": industry,
        "company": company,
        "department": department,
      };

  @override
  String toString() {
    return "$id, $groupname, $code, $city, $industry, $company,$department, ";
  }
}

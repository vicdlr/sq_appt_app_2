class CityModel {
  CityModel({
    required this.id,
    required this.city,
  });

  final int id;
  final String city;

  factory CityModel.fromJson(Map<String, dynamic> json){
    return CityModel(
      id: json["id"] ?? 0,
      city: json["city"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "city": city,
  };

  @override
  String toString(){
    return "$id, $city, ";
  }

}

/*
{
	"id": 1,
	"city": "New York"
}*/
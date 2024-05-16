class UserData {
  UserData({
    required this.id,
    required this.email,
    required this.username,
    required this.fcmToken,
    required this.city,
    required this.region,
    required this.customerId,
  });

   String id;
   String email;
   String username;
   String fcmToken;
   String city;
   String region;
   String customerId;

  factory UserData.fromJson(Map<String, dynamic> json){
    return UserData(
      id: json["id"].toString() ?? "",
      email: json["email"].toString() ?? "",
      username: json["username"].toString() ?? "",
      fcmToken: json["fcm_token"].toString() ?? "",
      city: json["city"].toString() ?? "",
      region: json["region"].toString() ?? "",
      customerId: json["customerId"].toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "username": username,
    "fcm_token": fcmToken,
    "city": city,
    "region": region,
    "customerId": customerId,
  };

  @override
  String toString(){
    return "$id, $email, $username, $fcmToken, $city, $region, $customerId, ";
  }

}

/*
{
	"id": "22",
	"email": "pradeep@gmail.com",
	"username": "pradeep ",
	"fcm_token": "ctZl234zSyqkZ1NfsJRMuU:APA91bF5XchVOOWx8PEbx4iuYhJ9gfauWUrG5d1-XN5Avt0iq8ge4PbaMUmO02r_v9yOtuj8ajFcfqajEuPMmE7H_DQ6eHCjBgNurKmskSf95_GLP37vkfl__hHCnquKRi1_ZUMotH8c",
	"city": "Moahli",
	"region": "Asia",
	"customerId": "gb71i4fokbch1jtx"
}*/
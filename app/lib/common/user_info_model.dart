import 'dart:convert';

UserInfoModel userInfoModelFromJson(String str) => UserInfoModel.fromJson(json.decode(str));

String userInfoModelToJson(UserInfoModel data) => json.encode(data.toJson());

class UserInfoModel {
  UserInfoModel(
      {required this.id,
      required this.phone,
      required this.email,
      required this.isVip,
      required this.vipEndedAt,
      required this.freeUsage});

  int id;
  String phone;
  String email;
  int freeUsage;
  bool isVip;
  DateTime vipEndedAt;
  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
        id: json["id"],
        phone: json["phone"],
        email: json["email"],
        freeUsage: json["freeUsage"] ?? 0,
        isVip: json["isVip"] ?? false,
        vipEndedAt: DateTime.parse(json["vipEndedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "phone": phone,
        "isVip": isVip,
        "freeUsage": freeUsage,
        "vipEndedAt": vipEndedAt.toIso8601String(),
      };
}

LoginInfoModel loginInfoModelFromJson(String str) => LoginInfoModel.fromJson(json.decode(str));

String loginInfoModelToJson(LoginInfoModel data) => json.encode(data.toJson());

class LoginInfoModel {
  LoginInfoModel({
    required this.token,
    required this.userInfo,
  });

  String token;
  UserInfoModel userInfo;

  factory LoginInfoModel.fromJson(Map<String, dynamic> json) => LoginInfoModel(
        token: json["token"],
        userInfo: UserInfoModel.fromJson(json["userInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "userInfo": userInfo.toJson(),
      };
}

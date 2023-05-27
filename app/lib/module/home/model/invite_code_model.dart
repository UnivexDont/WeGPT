import 'dart:convert';

InviteCodeModel inviteCodeModelFromJson(String str) => InviteCodeModel.fromJson(json.decode(str));

String inviteCodeModelToJson(InviteCodeModel data) => json.encode(data.toJson());

class InviteCodeModel {
  InviteCodeModel({
    required this.code,
  });

  String code;

  factory InviteCodeModel.fromJson(Map<String, dynamic> json) => InviteCodeModel(
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
      };
}

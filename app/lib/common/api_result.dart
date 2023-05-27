class ApiResult<T> {
  ApiResult({
    required this.success,
    required this.status,
    required this.code,
    required this.data,
    required this.message,
  });

  int status;
  String code;
  T? data;
  String message;
  bool success = false;

  factory ApiResult.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    final jsonData = json['data'];
    T? data;
    if (null != jsonData && Null != jsonData.runtimeType && Type != jsonData.runtimeType) {
      data = fromJsonT(json['data']);
    }
    final isSuccess = json['status'] == 200;
    return ApiResult(
      success: isSuccess,
      status: json["status"],
      code: json["code"],
      data: data,
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T? value) toJsonT) {
    final jsonData = toJsonT(data);
    return {
      "status": status,
      "code": code,
      "data": jsonData,
      "message": message,
    };
  }
}

extension StringExtension on String {
  bool get isPhoneNumber {
    const pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(this);
  }

  bool get isVerifyCode {
    const pattern = r'^\d{6}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(this);
  }

  bool get isInviteCode {
    if (length != 10) {
      return false;
    }
    final regex = RegExp(r'^[\w\p{P}]+$');
    return regex.hasMatch(this);
  }

  bool get isEmail {
    const pattern = r'^(?=.{1,256})(?=.{1,64}@.{1,255}$)[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(this);
  }
}

enum GRPCNetHeaderStatus { success, invaildToken, invalidSecret, outUsage, serverError, freeOver }

extension GRPCNetHeaderStatuser on GRPCNetHeaderStatus {
  static GRPCNetHeaderStatus fromRaw(int index) {
    switch (index) {
      case 0:
        return GRPCNetHeaderStatus.success;
      case 1:
        return GRPCNetHeaderStatus.invaildToken;
      case 2:
        return GRPCNetHeaderStatus.invalidSecret;
      case 3:
        return GRPCNetHeaderStatus.outUsage;
      case 4:
        return GRPCNetHeaderStatus.serverError;
      case 5:
        return GRPCNetHeaderStatus.freeOver;
    }
    return GRPCNetHeaderStatus.success;
  }
}

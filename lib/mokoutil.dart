class MoKoUtils {
  //将数组转成int
  static int bytes2int(List<int> bytes) {
    var iOutcome = 0;
    var i = 0;
    for (var length = bytes.length; i < length; i++) {
      var bLoop = bytes[i];
      iOutcome += (bLoop & 255) << 8 * (length - 1 - i);
    }
    return iOutcome;
  }

  static String bytesToHexString(List<int>? src) {
    StringBuffer buffer = StringBuffer("");
    if (src?.isNotEmpty == true) {
      for (int i = 0; i < src!.length; i++) {
        int v = src[i] & 255;
        String hv = v.toRadixString(16);
        if (hv.length < 2) buffer.write(0);
        buffer.write(hv);
      }
      return buffer.toString();
    } else {
      return "";
    }
  }
}

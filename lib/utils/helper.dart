class Helper {


  static bool isIpv4(String? value){
    if(value == null) return false;
    var regex = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
    return regex.hasMatch(value);
  }
}
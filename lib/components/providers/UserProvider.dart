import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String ambulanceno = 'ambulance no', drivername = '', mobileno = '8910902686';

  String get getambulaceno => ambulanceno;
  String get getdrivername => drivername;
  String get getmobileno => mobileno;
  void setambulanceno(String s) {
    ambulanceno = s;
    notifyListeners();
  }

  void setmobileno(String s) {
    mobileno = s;
    notifyListeners();
  }

  void setdrivername(String s) {
    drivername = s;
    notifyListeners();
  }
}

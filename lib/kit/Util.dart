import 'package:intl/intl.dart';

class Util{

  static String formatDay(DateTime dt){
    if(dt==null)return '';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static DateTime parseDay(String str){
    if(str==null)
      return null;
    return DateFormat("yyyy-MM-dd").parse(str);
  }


}
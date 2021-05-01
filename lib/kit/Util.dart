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


  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  static DateTime lastDayOfMonth(DateTime month) {
    final date = month.month < 12 ? DateTime.utc(month.year, month.month + 1, 1, 12) : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

}
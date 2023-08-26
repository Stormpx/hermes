import 'package:intl/intl.dart';

class Util{

  static String formatDay(DateTime? dt){
    if(dt==null)return '';
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static DateTime parseDay(String str){
    return DateFormat("yyyy-MM-dd").parse(str);
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  static DateTime lastDayOfMonth(DateTime month) {
    final date = month.month < 12 ? DateTime.utc(month.year, month.month + 1, 1, 0) : DateTime.utc(month.year + 1, 1, 1, 0);
    return date.subtract(const Duration(seconds: 1));
  }

}
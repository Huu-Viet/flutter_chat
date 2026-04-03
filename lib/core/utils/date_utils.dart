import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
  
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}
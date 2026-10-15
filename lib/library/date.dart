import 'package:intl/intl.dart';

extension BuddhistCalendarFormatter on DateFormat {
  String formatThai(DateTime dateTime) {
    if (pattern!.contains('y')) {
      var buddhistDateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.millisecond,
        dateTime.microsecond,
      );
      if (locale.contains('th') || locale.contains('TH')) {
        var normalYear = buddhistDateTime.year;
        var dateTimeString = format(buddhistDateTime).replaceAll('ค.ศ.', 'พ.ศ.');
        dateTimeString = dateTimeString.replaceAll(normalYear.toString(), (normalYear + 543).toString());
        return dateTimeString;
      } else {
        var result = format(buddhistDateTime);
        return result;
      }
    }
    return format(dateTime);
  }
}

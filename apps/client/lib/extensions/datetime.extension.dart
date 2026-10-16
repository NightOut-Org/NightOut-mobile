import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime get date {
    return copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  DateTime get time {
    return copyWith(year: 0, month: 0, day: 0);
  }

  String format([String? pattern]) {
    DateFormat dateFormat = DateFormat(pattern);
    return dateFormat.format(this);
  }

  bool get isToday {
    String today = DateTime.now().format("dd/MM/yyyy");
    String datetimeStr = format("dd/MM/yyyy");
    return (today == datetimeStr);
  }
}

extension DateTimeStringExtension on String {
  DateTime toDateTime({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime.parse(this).copyWith(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
      microsecond: microsecond,
    );
  }

  DateTime parseDateTime([String? pattern]) {
    DateFormat dateFormat = DateFormat(pattern);
    return dateFormat.parse(this);
  }
}

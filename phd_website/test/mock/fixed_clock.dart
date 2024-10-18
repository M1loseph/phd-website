import 'package:phd_website/clock/clock.dart';

class FixedClock implements Clock {
  static final defaultFixedDate = DateTime.parse('2020-10-10T10:10:10Z');

  late final DateTime date;

  FixedClock({
    DateTime? date,
  }) {
    if (date == null) {
      this.date = defaultFixedDate;
    } else {
      this.date = date;
    }
  }

  @override
  DateTime now() {
    return date;
  }
}

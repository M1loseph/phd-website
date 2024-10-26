import 'package:flutter_test/flutter_test.dart';
import 'package:phd_website/model/semester.dart';
import 'package:phd_website/model/semester_type.dart';
import 'package:phd_website/model/semester_year.dart';

import '../mock/fixed_clock.dart';

void main() {
  test('Given clock Then should calculate which semester this is', () {
    final semester = Semester.currentSemester(
        FixedClock(date: DateTime.parse('2023-01-01T00:00:00.0')));

    expect(const Semester(SemesterYear(2022), SemesterType.winter),
        equals(semester));
  });
}

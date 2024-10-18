import 'package:flutter_test/flutter_test.dart';
import 'package:phd_website/model/semester_year.dart';

void main() {
  test('Given some year Then should correctly calculate next year', () {
    const year = SemesterYear(2024);
    expect(year.firstYear, equals(2024));
    expect(year.secondYear, equals(2025));
  });
}

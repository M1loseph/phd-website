import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/model/semester_type.dart';
import 'package:phd_website/model/semester_year.dart';

class Semester {
  final SemesterYear year;
  final SemesterType type;

  const Semester(
    this.year,
    this.type,
  );

  static Semester currentSemester(Clock clock) {
    final now = clock.now();
    final isBeforeOctober = now.month < DateTime.october;
    final isBeforeMarch = now.month < DateTime.march;
    final firstYear = isBeforeOctober ? now.year - 1 : now.year;
    final semesterType = !isBeforeMarch && isBeforeOctober
        ? SemesterType.summer
        : SemesterType.winter;
    return Semester(
      SemesterYear(firstYear),
      semesterType,
    );
  }

  int countSemestersBetween(Semester other) {
    final first = year.firstYear * 2 + (type == SemesterType.winter ? 0 : 1);
    final second =
        other.year.firstYear * 2 + (other.type == SemesterType.winter ? 0 : 1);
    return (first - second).abs();
  }

  @override
  bool operator ==(Object other) {
    if (other is! Semester) {
      return false;
    }
    return type == other.type && year == other.year;
  }

  @override
  String toString() {
    return '${year.firstYear}/${year.secondYear} - ${type.name}';
  }

  @override
  int get hashCode => Object.hash(year, type);
}

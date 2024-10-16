import 'package:flutter/material.dart';
import 'package:phd_website/clock/clock.dart';

class SemesterPicker extends StatefulWidget {
  const SemesterPicker({
    super.key,
  });

  @override
  State<SemesterPicker> createState() => _SemesterPickerState();
}

class _SemesterPickerState extends State<SemesterPicker> {
  static const dropdownWidth = 250.0;
  static const firstYear = Semester(
    years: SemesterYear(firstYear: 2023),
    type: SemesterType.winter,
  );

  late final Semester currentSemester;
  late final int numberOfSemesters;

  @override
  void initState() {
    currentSemester = Semester.currentSemester(Clock());
    numberOfSemesters = firstYear.countSemestersBetween(currentSemester);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final semstersAsYears = numberOfSemesters ~/ 2 + 2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<SemesterYear>(
          dropdownMenuEntries: List.generate(semstersAsYears, (offset) {
            final year = firstYear.years.firstYear + offset;
            final semesterYear = SemesterYear(firstYear: year);
            return DropdownMenuEntry(
              value: semesterYear,
              label: '${semesterYear.firstYear} / ${semesterYear.secondYear}',
            );
          }),
          label: const Text('Year'),
          initialSelection: currentSemester.years,
          menuHeight: 300,
          width: dropdownWidth,
        ),
        const SizedBox(
          width: 30,
        ),
        DropdownMenu<SemesterType>(
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              value: SemesterType.winter,
              label: 'Winter',
            ),
            DropdownMenuEntry(
              value: SemesterType.summer,
              label: 'Summer',
            )
          ],
          label: const Text('Season'),
          initialSelection: currentSemester.type,
          width: dropdownWidth,
        )
      ],
    );
  }
}

class SemesterYear {
  final int firstYear;

  const SemesterYear({required this.firstYear});

  int get secondYear => firstYear + 1;

  @override
  bool operator ==(Object other) {
    if (other is! SemesterYear) {
      return false;
    }
    return firstYear == other.firstYear;
  }

  @override
  int get hashCode => firstYear.hashCode;
}

class Semester {
  final SemesterYear years;
  final SemesterType type;

  const Semester({
    required this.years,
    required this.type,
  });

  static Semester currentSemester(Clock clock) {
    final now = clock.now();
    final isBeforeOctober = now.month < DateTime.october;
    final isBeforeMarch = now.month < DateTime.march;
    final firstYear = isBeforeOctober ? now.year - 1 : now.year;
    final semesterType = !isBeforeMarch && isBeforeOctober
        ? SemesterType.summer
        : SemesterType.winter;
    return Semester(
      years: SemesterYear(firstYear: firstYear),
      type: semesterType,
    );
  }

  int countSemestersBetween(Semester other) {
    final first = years.firstYear * 2 + (type == SemesterType.winter ? 0 : 1);
    final second =
        other.years.firstYear * 2 + (other.type == SemesterType.winter ? 0 : 1);
    return (first - second).abs();
  }

  @override
  String toString() {
    return '${years.firstYear}/${years.secondYear} - ${type.name}';
  }
}

enum SemesterType {
  winter,
  summer,
}

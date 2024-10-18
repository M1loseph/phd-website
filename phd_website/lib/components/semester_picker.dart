import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/clock/clock.dart';

class SemesterPicker extends StatefulWidget {
  final void Function(Semester?) selectSemesterCallback;

  const SemesterPicker({
    super.key,
    required this.selectSemesterCallback,
  });

  @override
  State<SemesterPicker> createState() => _SemesterPickerState();
}

class _SemesterPickerState extends State<SemesterPicker> {
  static const firstYear = Semester(
    SemesterYear(2023),
    SemesterType.winter,
  );

  late final Semester currentSemester;
  late final int numberOfSemesters;

  SemesterYear? selectedSemesterYear;
  SemesterType? selectedSemesterType;

  @override
  void initState() {
    currentSemester = Semester.currentSemester(Clock());
    selectedSemesterYear = currentSemester.year;
    selectedSemesterType = currentSemester.type;
    numberOfSemesters = firstYear.countSemestersBetween(currentSemester);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final semestersAsYears = numberOfSemesters ~/ 2 + 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: DropdownMenu<SemesterYear>(
            dropdownMenuEntries: List.generate(semestersAsYears, (offset) {
              final year = firstYear.year.firstYear + offset;
              final semesterYear = SemesterYear(year);
              return DropdownMenuEntry(
                value: semesterYear,
                label: '${semesterYear.firstYear} / ${semesterYear.secondYear}',
              );
            }),
            initialSelection: currentSemester.year,
            menuHeight: 300,
            // https://github.com/flutter/flutter/issues/137514#issuecomment-1784709841
            expandedInsets: EdgeInsets.zero,
            onSelected: (year) {
              setState(() {
                selectedSemesterYear = year;
              });
              checkIfBothValuesAreSelected();
            },
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        Expanded(
          child: DropdownMenu<SemesterType>(
            key: UniqueKey(),
            dropdownMenuEntries:
                [SemesterType.winter, SemesterType.summer].map((type) {
              return DropdownMenuEntry(
                value: type,
                label:
                    locale.componentSemesterPicker_semesterTypeName(type.name),
              );
            }).toList(),
            onSelected: (type) {
              setState(() {
                selectedSemesterType = type;
              });
              checkIfBothValuesAreSelected();
            },
            initialSelection: currentSemester.type,
            expandedInsets: EdgeInsets.zero,
          ),
        )
      ],
    );
  }

  void checkIfBothValuesAreSelected() {
    if (selectedSemesterType == null || selectedSemesterType == null) {
      widget.selectSemesterCallback(null);
      return;
    }
    widget.selectSemesterCallback(
      Semester(
        selectedSemesterYear!,
        selectedSemesterType!,
      ),
    );
  }
}

// TODO: write tests
class SemesterYear {
  final int firstYear;

  const SemesterYear(this.firstYear);

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

enum SemesterType {
  winter,
  summer,
}

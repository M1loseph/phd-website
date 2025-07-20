import 'package:flutter/material.dart';
import 'package:phd_website/l10n/app_localizations.dart';
import 'package:phd_website/model/semester.dart';
import 'package:phd_website/model/semester_type.dart';
import 'package:phd_website/model/semester_year.dart';

class SemesterPicker extends StatefulWidget {
  final void Function(Semester) selectSemesterCallback;
  final Semester currentSemester;

  const SemesterPicker({
    super.key,
    required this.selectSemesterCallback,
    required this.currentSemester,
  });

  @override
  State<SemesterPicker> createState() => _SemesterPickerState();
}

class _SemesterPickerState extends State<SemesterPicker> {
  final controller = TextEditingController();
  static const firstYear = Semester(
    SemesterYear(2023),
    SemesterType.winter,
  );

  late final int numberOfSemesters;

  late SemesterYear selectedSemesterYear;
  late SemesterType selectedSemesterType;

  @override
  void initState() {
    selectedSemesterYear = widget.currentSemester.year;
    selectedSemesterType = widget.currentSemester.type;
    numberOfSemesters = firstYear.countSemestersBetween(widget.currentSemester);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    controller.text = locale
        .componentSemesterPicker_semesterTypeName(selectedSemesterType.name);
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
                label: '${semesterYear.firstYear}/${semesterYear.secondYear}',
              );
            }),
            initialSelection: widget.currentSemester.year,
            menuHeight: 300,
            // https://github.com/flutter/flutter/issues/137514#issuecomment-1784709841
            expandedInsets: EdgeInsets.zero,
            onSelected: (year) {
              if (year == null) {
                return;
              }
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
            controller: controller,
            dropdownMenuEntries:
                [SemesterType.winter, SemesterType.summer].map((type) {
              return DropdownMenuEntry(
                value: type,
                label:
                    locale.componentSemesterPicker_semesterTypeName(type.name),
              );
            }).toList(),
            onSelected: (type) {
              if (type == null) {
                return;
              }
              setState(() {
                selectedSemesterType = type;
              });
              checkIfBothValuesAreSelected();
            },
            initialSelection: widget.currentSemester.type,
            expandedInsets: EdgeInsets.zero,
          ),
        )
      ],
    );
  }

  void checkIfBothValuesAreSelected() {
    widget.selectSemesterCallback(
      Semester(
        selectedSemesterYear,
        selectedSemesterType,
      ),
    );
  }
}

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

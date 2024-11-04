import 'package:phd_website/build_properties/build_properties.dart';

class FixedBuildProperties implements BuildProperties {
  static const fixedVersion = '1.1';
  static const fixedYear = 2024;

  final String version;
  final int year;

  FixedBuildProperties({
    this.version = fixedVersion,
    this.year = fixedYear,
  });

  @override
  String get appVersion => version;

  @override
  int get lastBuildYear => year;
}

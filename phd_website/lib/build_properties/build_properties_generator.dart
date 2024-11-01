import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

abstract class VersionSourceRunner {
  FutureOr<String> getGitVersion();
}

class GitVersionSourceRunner implements VersionSourceRunner {
  static const appNameSeparator = '/';

  @override
  FutureOr<String> getGitVersion() async {
    final processResult = await Process.run('git', [
      'describe',
      '--tags',
      '--match="phdwebsite/**"',
    ]);
    if (processResult.exitCode != 0) {
      throw Exception(
          'Error occurred when running git. Exit code: ${processResult.exitCode}. Stderr: ${processResult.stderr}');
    }
    final version = (processResult.stdout as String).trim();
    final partsIndex = version.indexOf(appNameSeparator);
    if (version.isEmpty ||
        !version.startsWith('phdwebsite') ||
        partsIndex == -1) {
      throw Exception('Unexpected version format: $version');
    }
    return version.substring(partsIndex + 1);
  }
}

class AppPropertiesGenerator extends Generator {
  final VersionSourceRunner gitVersionSourceRunner;

  AppPropertiesGenerator({required this.gitVersionSourceRunner});

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final version = await gitVersionSourceRunner.getGitVersion();
    return '''
      class GitBuildProperties implements BuildProperties {
        @override
        String get appVersion => '$version';

        @override
        int get lastBuildYear => ${DateTime.now().year};
     }
    ''';
  }
}

Builder buildPropertiesGenerator(BuilderOptions options) => SharedPartBuilder(
      [
        AppPropertiesGenerator(
          gitVersionSourceRunner: GitVersionSourceRunner(),
        )
      ],
      'build_properties',
    );

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

abstract class VersionSourceRunner {
  FutureOr<String> getGitVersion();
}

class GitVersionSourceRunner implements VersionSourceRunner {
  @override
  FutureOr<String> getGitVersion() async {
    return Process.run('git', ['describe', '--tags']).then((processResult) {
      return (processResult.stdout as String).trim();
    });
  }
}

class AppPropertiesGenerator extends Generator {
  final VersionSourceRunner gitVersionSourceRunner;

  AppPropertiesGenerator({required this.gitVersionSourceRunner});

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final version = await gitVersionSourceRunner.getGitVersion();
    return '''
      extension BuildPropertiesExtension on BuildProperties {
        String get appVersion => '$version';

        String get lastBuildYear => '${DateTime.now().year}';
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

import 'dart:async';
import 'dart:io';

import 'package:new_dcdg/src/src/build_diagram.dart';
import 'package:new_dcdg/src/src/command_line.dart';
import 'package:new_dcdg/src/src/configuration.dart';
import 'package:new_dcdg/src/src/find_class_elements.dart';
import 'package:path/path.dart' as path;

Future<Null> main(Iterable<String> arguments) async {
  final config = Configuration.fromCommandLine(arguments);

  if (config.shouldShowHelp) {
    print(makeHelp());
    exit(0);
  }

  if (config.shouldShowVersion) {
    print(makeVersion());
    exit(0);
  }

  if (config.builder == null) {
    outputError('Builder "${config.builderName}" was not found');
    exit(1);
  }
  final builder = config.builder!;

  final pubspec = File(path.join(config.packagePath, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    outputError('No Dart package found at "${config.packagePath}"');
    exit(1);
  }

  final classes = await findClassElements(
    exportedOnly: config.exportedOnly,
    packagePath: config.packagePath,
    searchPath: config.searchPath,
  );

  buildDiagram(
    builder: builder,
    classElements: classes,
    excludeHasA: config.excludeHasA,
    excludeIsA: config.excludeIsA,
    excludePrivateClasses: config.excludePrivateClasses,
    excludePrivateFields: config.excludePrivateFields,
    excludePrivateMethods: config.excludePrivateMethods,
    excludes: config.excludeExpressions,
    hasA: config.hasAExpressions,
    includes: config.includeExpressions,
    isA: config.isAExpressions,
    verbose: config.verbose,
  );

  // Output the diagram as a PlantUML file
  if (config.outputPath == '') {
    builder.printContent(print);
  } else {
    final outFile = File(config.outputPath);
    try {
      if (!outFile.path.endsWith('.puml')) {
        outputError(
          'Output file must have a .puml extension to save as PlantUML.',
        );
        exit(1);
      }
      builder.writeContent(outFile);
      print('PlantUML diagram saved to: ${outFile.path}');
    } on FileSystemException catch (exception) {
      outputError(
        'Failed writing to file ${exception.path} (${exception.osError})',
        exception,
      );
      exit(1);
    }
  }
}

void outputError(String message, [Exception? exception]) {
  stderr.writeln('Error: $message');
  if (exception != null) {
    stderr.writeln(exception.toString());
  }
}
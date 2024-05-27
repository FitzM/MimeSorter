// ignore_for_file: unused_local_variable, duplicate_ignore

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'logic.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addOption(
      'source_Directory',
      help: "directory of the files you want to sort",
      abbr: 'S',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('mime_sorter version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }
    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
    //
    //SPACER
    //SPACER
    //
    var targetDirectory =
        results.option('source_Directory') ?? Directory.current.path;
    targetDirectory = p.isAbsolute(targetDirectory)
        ? targetDirectory
        : p.absolute(targetDirectory);
    mainMimeTyperFunction(targetDirectory);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

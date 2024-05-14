import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

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
    ..addOption('source_Directory',
        help: "directory of the files you want to sort",
        abbr: 'S',
        defaultsTo: Directory.current.path)
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
    var targetDirectory = results.option('source_Directory')!;
    mimeTyper(targetDirectory);

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

void mimeTyper(String targetDirectory) async {
  checkPath(targetDirectory);
  print("We proceeded");

  var files = Directory(p.absolute(targetDirectory))
      .list(recursive: true, followLinks: true);

  await for (var fileToSort in files) {
    //moveFiles(fileToSort, targetDirectory);
    logFiles(fileToSort);
  }
}

checkPath(String targetDirectory) {
  targetDirectory = p.isAbsolute(targetDirectory)
      ? targetDirectory
      : p.absolute(targetDirectory);
  var proceed =
      confirm("Did you want to use $targetDirectory", defaultValue: false);
  proceed == true ? "" : exit(0);
}

moveFiles(FileSystemEntity targetFile, String targetDirectory) {
  var targetFilePath = targetFile.path;
  var fileType = lookupMimeType(targetFilePath);
  var macroTypeDirectory = fileType?.split('/').firstOrNull ?? "Unknown";
  String newDirectoryName =
      p.join(p.dirname(targetFilePath), macroTypeDirectory);
  Directory(newDirectoryName).createSync();
  try {
    move(targetFile.path, newDirectoryName);
  } catch (error) {
    error.toString().contains("The 'from' argument")
        ? print("FROM ERROR!!")
        : print(error);
  }
}

logFiles(FileSystemEntity targetFile) {
  print(lookupMimeType(targetFile.path));
}

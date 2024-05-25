// ignore_for_file: unused_local_variable, duplicate_ignore

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import './magic_numbers.dart';
import 'package:path/path.dart' as p;

const String version = '0.0.1';
var resolver = mimeTypeResolver();

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
    var targetDirectory =
        results.option('source_Directory') ?? Directory.current.path;
    targetDirectory = p.isAbsolute(targetDirectory)
        ? targetDirectory
        : p.absolute(targetDirectory);
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
  targetDirectory = checkPath(targetDirectory);
  print("We proceeded");
  print(targetDirectory);
  /*  var files = Directory(p.normalize(targetDirectory))
      .list(recursive: true, followLinks: true);

  await for (var fileToSort in files) {
    //moveFiles(fileToSort, targetDirectory);
    fileToSort is Directory
        ? print("Skipping $fileToSort because it is a Directory")
        : moveFiles(fileToSort, targetDirectory);
  } */
}

String checkPath(String targetDirectory) {
  targetDirectory = p.absolute(targetDirectory);
  targetDirectory = p.canonicalize(targetDirectory);
  var proceed =
      confirm("Did you want to use $targetDirectory", defaultValue: false);
  proceed == true ? "" : exit(0);
  return targetDirectory;
}

moveFile(FileSystemEntity targetFile, String targetDirectory) async {
  var exifType = await Process.start('exiftool', [targetFile.path]);
  // ignore: unused_local_variable
  var macroTypeDirectory = "Unknown";

  // ignore: unused_local_variable
  var marcoDirr = exifType.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((line) => line.toString().contains("MIME Type"));
  exifType.stdout
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((line) {
    if (line.toString() != "") {
      print(line);
      var macroDir = line
          .split(":")
          .lastWhere((element) => element.contains("/"))
          .split('/')
          .first;
      var macroTypeDirectory = macroDir;
      print("Inline: $macroDir ");
    }
  }).toString();
}

moveFileFunction(FileSystemEntity targetFile, String macroTypeDirectory) {
  String newDirectoryName =
      p.join(p.dirname(targetFile.path), macroTypeDirectory);
  Directory(newDirectoryName).createSync();
  try {
    move(targetFile.path, newDirectoryName);
  } catch (error) {
    error.toString().contains("The 'from' argument")
        ? print("FROM ERROR!!")
        : print(error);
  }
}

Future<String> findMIMEType(FileSystemEntity targetFile) async {
  var completer = Completer<String>();
  var exifType = await Process.start('exiftool', [targetFile.path]);
  exifType.stdout.transform(utf8.decoder).transform(LineSplitter()).listen(
      (line) {
    if (line.contains("MIME Type")) {
      completer.complete(line.split(':').last.trim().split("/").first);
    }
  }, onDone: () {
    if (!completer.isCompleted) {
      completer.complete('unknown');
    }
  });

  return completer.future;
}

logFiles(FileSystemEntity targetFile) async {
  var filePath = targetFile.path;
  var dirName = resolver.lookup(filePath,
          headerBytes: await File(filePath).openRead(0, 25).first) ??
      'null';
  dirName.contains('audio') ? print(' : $dirName') : null;
  if (filePath.contains('3651')) print(filePath);
}

moveFiles(FileSystemEntity targetFile, String targetDirectory) async {
  var filePath = targetFile.path;
  var dirName = resolver.lookup(filePath,
          headerBytes: await File(filePath).openRead(0, 25).first) ??
      'null';
  var sortedDir = dirName != "null" ? dirName.split("/").first : 'Unknown';
  await Directory(sortedDir).create();
  try {
    move(filePath, sortedDir);
    print(p.basename(filePath));
  } catch (error) {
    error.toString().contains("The 'from' argument")
        ? print("FROM ERROR!!")
        : print(error);
  }
}

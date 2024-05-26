import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dcli/dcli.dart';
import 'package:mime/mime.dart';

void mimeTyper(String targetDirectory) async {
  targetDirectory = checkPath(targetDirectory);
  print("We proceeded");
  print(targetDirectory);
  var files = Directory(p.normalize(targetDirectory))
      .list(recursive: true, followLinks: true);

  await for (var fileToSort in files) {
    //moveFiles(fileToSort, targetDirectory);
    logFiles(fileToSort, targetDirectory);
  }
}

String checkPath(String targetDirectory) {
  targetDirectory = p.absolute(targetDirectory);
  targetDirectory = p.canonicalize(targetDirectory);
  var proceed =
      confirm("Did you want to use $targetDirectory", defaultValue: false);
  proceed == true ? "" : exit(0);
  return targetDirectory;
}

moveFiles(FileSystemEntity targetFile, String targetDirectory) async {
  var filePath = targetFile.path;
  var dirName = lookupMimeType(filePath,
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

logFiles(FileSystemEntity targetFile, String dir) async {
  if (targetFile is! Directory) {
    var filePath = targetFile.path;
    if (filePath.endsWith(".tmp")) {
    var dirName = lookupMimeType(filePath,
            headerBytes: await File(filePath).openRead(0, 25).first) ??
        'null';
    dirName.contains('audio') ? print(' : $filePath') : print(dirName);
    dirName.contains('null') ? print('/n ========$filePath') : null;
  }
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

//
//
//
//

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

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dcli/dcli.dart';
import 'package:mime/mime.dart';

void mainMimeTyperFunction(String targetDirectory) async {
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

moveFiles(FileSystemEntity targetFile, String targetDirectory) async {}

logFiles(FileSystemEntity targetFile, String dir) async {
  const indentWidth = 15;
  var typesFromLogicFunction = await getTypesLogic(targetFile);
  var formattedTypesMicro = formatMimeType(typesFromLogicFunction, false);
  var formattedTypesMacro = formatMimeType(typesFromLogicFunction, true);
  print("""
${'======== File Name:'.padRight(indentWidth + 8)}  ${targetFile.path}  
         ${'MacroType:'.padRight(indentWidth)} $formattedTypesMacro 
         ${'MicroType:'.padRight(indentWidth)} $formattedTypesMicro
         """);
}

String checkPath(String targetDirectory) {
  targetDirectory = p.normalize(targetDirectory);
  targetDirectory = p.canonicalize(targetDirectory);
  var proceed =
      confirm("Did you want to use $targetDirectory", defaultValue: false);
  proceed == true ? "" : exit(0);
  return targetDirectory;
}

Future<String> getTypesLogic(FileSystemEntity targetFile) async {
  if (targetFile is! Directory) {
    var filePath = targetFile.path;
    String macroDirName = '';
    var fileHeaderBytes = List.filled(defaultMagicNumbersMaxLength, 0);
    try {
      fileHeaderBytes =
          await File(filePath).openRead(0, defaultMagicNumbersMaxLength).first;
    } catch (e) {
      print(e);
    }

    macroDirName = fileHeaderBytes.any((element) => element != 0)
        ? (lookupMimeType(filePath, headerBytes: fileHeaderBytes) ?? "unknown")
        : "unknown";
    if (macroDirName.contains("mp4") || macroDirName.contains("unknown")) {
      macroDirName = await findExifType(filePath);
    }
    return macroDirName;
  }
  return "";
}

Future<String> findExifType(String filePath) async {
  var exifToolType = await Process.run('exiftool', ["-mimetype", filePath]);
  var exifToolTypeString = exifToolType.stdout
      .toString()
      .toLowerCase()
      .replaceFirst("mime type ", "")
      .replaceFirst(":", "")
      .trim();
  print("/===== ExifToolUsed:  $exifToolTypeString =======/");

  return exifToolTypeString;
}

String formatMimeType(String mimeType, [bool macroOrMicro = false]) {
  var splitFormat = mimeType.split("/");
  var formattedMimeType =
      (macroOrMicro ? splitFormat.firstOrNull : splitFormat.lastOrNull) ??
          "Unknown";
  return formattedMimeType;
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

//
//
//
//


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
    moveFiles(fileToSort, targetDirectory);
    // logFiles(fileToSort, targetDirectory);
  }
}

Future<void> moveFiles(
    FileSystemEntity targetFile, String targetDirectory) async {
  var targetFilePath = targetFile.path;
  var typesFromLogicFunction = await getTypesLogic(targetFile);
  var dirFromType = formatMimeType(typesFromLogicFunction);
  dirFromType =
      dirFromType.contains("/") ? dirFromType.split("/").last : dirFromType;
  var targetDirPath = p.join(targetDirectory, dirFromType);
  var fileRenamePath = p.join(targetDirPath, p.basename(targetFilePath));
  if (!Directory(targetDirPath).existsSync()) {
    try {
      Directory(targetDirPath).createSync(recursive: true);
    } catch (error) {
      if (error.toString().contains("Not a directory")) {
        Directory(targetDirPath).createSync(recursive: true);
      }
    }
  }
  try {
    await (targetFile as File).rename(fileRenamePath);
    print('File moved to $fileRenamePath');
  } catch (error) {
    await (targetFile as File).rename(fileRenamePath);
    print('Error moving file: $error');
  }
}

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
      (macroOrMicro ? splitFormat.lastOrNull : splitFormat.firstOrNull) ??
          "Unknown";
  return formattedMimeType;
}


//
//
//
//


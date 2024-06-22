import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:args/args.dart';
import 'package:mime_parser/mime_magic_numbers.dart';

var movedCounter = 0;
var errorCounter = 0;

ArgParser buildParser() {
  return ArgParser()
    ..addOption('sortDirectory',
        abbr: 'D',
        mandatory: false,
        defaultsTo: Directory.current.path,
        help:
            "What directory do you want to sort? If nothing is passed, the current directory will be used.");
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();

  final ArgResults results = argParser.parse(arguments);
  var parsedDirectory = results['sortDirectory'] as String;
  var proceed = ask("Use this directory?\n$parsedDirectory ",
      required: true, defaultValue: "No", toLower: true)[0];
  if (!["y", "yes"].contains(proceed) || proceed.length > 3) exit(0);

  final stopWatch = Stopwatch()..start();
  await sortDirectory(parsedDirectory);
  stopWatch.stop();

  print("Sorting completed in ${stopWatch.elapsedMilliseconds}ms.");
  print("Total time elapsed: ${stopWatch.elapsed}");

  print("Moved Files: $movedCounter \nError Files: $errorCounter");
}

Future<void> sortDirectory(String sortDirectory) async {
  Stream<FileSystemEntity> fileStream =
      Directory(sortDirectory).list(followLinks: true, recursive: true);

  await for (final FileSystemEntity file in fileStream) {
    if (file is File) {
      final mimeType = await getMimeTypeByMagicNumbers(file);
      var typeDirectory = mimeType?.split("/").first.toLowerCase() ?? "unknown";
      var fileName = p.basename(file.path);
      await Directory(p.join(sortDirectory, typeDirectory))
          .create(recursive: true);
      try {
        move(file.path,
            p.join(sortDirectory, typeDirectory, p.basename(file.path)),
            overwrite: false);
        movedCounter++;
      } catch (e) {
        print(e);
        errorCounter++;
      }
      print("Moved $fileName");
    }
  }
}

Future<String?> getMimeTypeByMagicNumbers(File file) async {
  final bytes = await file.openRead(0, 1024).first; // Read first 1024 bytes

  for (var magicNumber in mimeMagicNumbers) {
    bool match = true;
    for (var i = 0; i < magicNumber.pattern.length; i++) {
      if (magicNumber.offset + i >= bytes.length) {
        match = false;
        break;
      }
      if (bytes[magicNumber.offset + i] != magicNumber.pattern[i]) {
        match = false;
        break;
      }
    }
    if (match) {
      return magicNumber.mimeType;
    }
  }

  return null; // Unknown MIME type
}

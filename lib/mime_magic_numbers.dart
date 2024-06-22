import 'dart:io';
import 'package:xml/xml.dart';

class MimeMagicNumberObject {
  final List<int> pattern;
  final String mimeType;
  final int offset;

  MimeMagicNumberObject(this.pattern, this.mimeType, this.offset);
}

Future<List<MimeMagicNumberObject>> parseMimeDatabase(String xmlPath) async {
  final file = File(xmlPath);
  final document = XmlDocument.parse(await file.readAsString());
  final mimeTypes = document.findAllElements('mime-type');
  final magicNumbers = <MimeMagicNumberObject>[];

  for (var mimeType in mimeTypes) {
    final type = mimeType.getAttribute('type');
    final magics = mimeType.findAllElements('magic');

    for (var magic in magics) {
      for (var match in magic.findAllElements('match')) {
        final value = match.getAttribute('value');
        final offsetStr = match.getAttribute('offset');
        if (value == null || offsetStr == null)
          continue; // Skip if no value or offset is provided

        int offset;
        try {
          offset = int.parse(offsetStr);
        } catch (e) {
          print('Error parsing offset: $offsetStr');
          continue; // Skip this entry if offset is invalid
        }

        // Convert the string value to bytes using UTF-8 encoding
        final pattern = value.codeUnits;

        magicNumbers.add(MimeMagicNumberObject(pattern, type!, offset));
      }
    }
  }

  return magicNumbers;
}

void main() async {
  final magicNumbers =
      await parseMimeDatabase('path/to/freedesktop.org.xml.in');
  for (var magic in magicNumbers) {
    print(
        'MIME Type: ${magic.mimeType}, Pattern: ${magic.pattern}, Offset: ${magic.offset}');
  }
}

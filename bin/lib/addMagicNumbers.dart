// ignore: file_names
import 'package:mime/mime.dart';

class MimeMagicNumberObject {
  final List<int> headerBytes;
  final String mimeType;
  List<int>? mask;

  MimeMagicNumberObject(this.headerBytes, this.mimeType, {this.mask}) {
    mask = mask ?? List.filled(headerBytes.length, 0xFF);
  }
}

final List<MimeMagicNumberObject> customMimeTypes = [
  MimeMagicNumberObject([
    0x00,
    0x01,
    0x00,
    0x00,
    0x53,
    0x74,
    0x61,
    0x6e,
    0x64,
    0x61,
    0x72,
    0x64,
    0x20,
    0x4a,
    0x65,
    0x74
  ], "ms-access.application"),
  MimeMagicNumberObject(
      [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C], "7z-compressed/application"),
  MimeMagicNumberObject(
    [
      0x53,
      0x51,
      0x4c,
      0x69,
      0x74,
      0x65,
      0x20,
      0x66,
      0x6f,
      0x72,
      0x6d,
      0x61,
      0x74,
      0x20,
      0x33,
      0x00
    ],
    "sqlite3/application",
    mask: [
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ],
  ),
  MimeMagicNumberObject(
    [
      0x01,
      0x0F,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x02,
      0x00,
      0x00,
      0x00,
      0x02,
      0x00,
      0x00
    ],
    "ms-sql/application",
    mask: [
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ],
  ),
  MimeMagicNumberObject(
    [
      0xFE,
      0x01,
      0x0B,
      0x04,
      0x00,
      0x00,
      0x00,
      0x04,
      0x00,
      0x00,
      0x00,
      0x08,
      0x00,
      0x00,
      0x00,
      0x0C
    ],
    "mysql/application",
    mask: [
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ],
  ),
  MimeMagicNumberObject(
    [
      0x50,
      0x47,
      0x45,
      0x53,
      0x51,
      0x4C,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x00
    ],
    "postgresql/application",
    mask: [
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF,
      0xFF
    ],
  )
];

void addMagicNumbers(
    MimeTypeResolver resolver, MimeMagicNumberObject magicNumberObject) {
  resolver.addMagicNumber(
    magicNumberObject.headerBytes,
    magicNumberObject.mimeType,
    mask: magicNumberObject.mask,
  );
}

void addAllExtraMagicNumbers() {
  final resolver = MimeTypeResolver();
  for (final magicNumber in customMimeTypes) {
    addMagicNumbers(resolver, magicNumber);
  }
  print("Extra Magic Added");
}

import 'dart:io';

void main() {
  printWithDelay1("Welcome to Dart 1");
  printWithDelay2("Welcome to Dart 2");
  createDescriptions(["mercury", "venus", "earth", ]);
}

Future<void> printWithDelay1(String message) async {
  await Future.delayed(Duration(seconds: 2));
  print(message);
}

Future<void> printWithDelay2(String message) {
  return Future.delayed(Duration(seconds: 1)).then((_) {
    print(message);
  });
}

Future<void> createDescriptions(Iterable<String> objects) async {
  for (final object in objects) {
    try {
      var file = File('$object.txt');
      if (await file.exists()) {
        var modified = await file.lastModified();
        print('File for $object already exists: ${file.absolute}. Last modified: $modified.');
        continue;
      }
      await file.create();
      await file.writeAsString('Start describing $object in this file.');
      print("Created file $file at ${file.absolute}");
    } on IOException catch (e) {
      print('Cannot create description for $object: $e');
    }
  }
}

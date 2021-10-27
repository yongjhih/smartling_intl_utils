import 'dart:io';

import 'package:path/path.dart' as Path;
import 'package:collection/collection.dart';

File? getSmartlingFileForLocale(
    String locale, String folderName, [String? basePath]) =>
    File(Path.join(
        basePath ?? Directory.current.path,
        folderName,
        '$locale.json',
    )).existsOrNull();

/// Gets all smartling files
List<FileSystemEntity> getSmartlingFiles(String folderName) =>
    Directory(Path.join(Directory.current.path, folderName))
        .listSync()
        // arb files order is not the same on all operating systems (e.g. win, mac)
        .where((file) => Path.basename(file.path).endsWith('.json'))
        .toList()
      ..sortBy((it) => it.path);

/// {locale}.json
List<String> getLocales(String folderName) =>
    getSmartlingFiles(folderName)
      .map((file) => Path.basename(file.path))
      .map((fileName) =>
      fileName.substring(0, fileName.length - '.json'.length))
      .toList();

extension FileX<T extends File> on T {
  T? existsOrNull() => existsSync() ? this : null;
  T existsOrThrow() {
    if (!existsSync()) {
      throw Exception(this.path);
    }
    return this;
  }
}

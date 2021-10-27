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

/// Gets all Smartling files
List<File> getSmartlingFiles(String folderName) =>
    Directory(Path.join(Directory.current.path, folderName))
        .listFilesSync()
        // arb files order is not the same on all operating systems (e.g. win, mac)
        .where((file) => Path.basename(file.path).endsWith('.json'))
        .toList()
      ..sortBy((it) => it.path);

List<String> getLocalesFromFiles(Iterable<File> files) =>
    files
      .map((file) => file.locale)
      .toList();

extension DirectoryX<T extends Directory> on T {
  List<File> listFilesSync() => listSync()
      .where((it) => FileSystemEntity.typeSync(it.path) == FileSystemEntityType.file)
      .whereType<File>()
      .toList();
}

extension FileX<T extends File> on T {
  T? existsOrNull() => existsSync() ? this : null;

  T existsOrThrow() {
    if (!existsSync()) {
      throw Exception(this.path);
    }
    return this;
  }

  /// {locale}.json
  /// .substring(0, Path.basename(path).length - Path.extension(path).length);
  String get locale =>
      Path.basenameWithoutExtension(path);
}

extension ArbStringX<T extends String> on T {
  /// ```
  /// {{%1s}}
  /// ```
  String smartlingToArbFormat([RegExp? regex]) {
    regex ??= RegExp(r'{{%(\d+)s}}');
    return replaceAllMapped(regex, (match) => "{{it${match.group(1)}}}");
  }
}

extension SmartlingMapX<T extends Map<String, Map<String, dynamic>>> on T {
  /// ```
  /// {
  ///   "smartling": { {} }
  ///   "key": { "translation": "xxx" },
  ///   "key2": { "translation": "xxx" },
  /// }
  /// ```
  Map<String, String> toArb() {
    final Map<String, String> newJson = {};
    remove("smartling");
    for (final entity in entries) {
      final String value = entity.value["translation"];
      newJson[entity.key] = value.smartlingToArbFormat();
    }
    return newJson;
  }
}


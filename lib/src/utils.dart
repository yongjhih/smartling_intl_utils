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
    return replaceAllMapped(regex, (match) => "{s${match.group(1)}}");
  }
}

extension SmartlingMapX<T extends Map<String, dynamic>> on T {
  /// ```
  /// {
  ///   "smartling": { {} }
  ///   "key": { "translation": "xxx" },
  ///   "key2": { "translation": "xxx" },
  /// }
  /// ```
  Map<String, dynamic> toArb({bool placeholdersEnabled = true}) {
    final Map<String, dynamic> newJson = {};
    for (final entity in entries) {
      if (entity.key == "smartling") {
        continue;
      }
      if (entity.key.startsWith(RegExp(r'@'))) {
        continue;
      }
      final String value = entity.value["translation"];
      final String arbValue = value.smartlingToArbFormat();
      newJson[entity.key] = arbValue;
      if (placeholdersEnabled) {
        final formats = RegExp(r'{(\w+)}').allMatches(arbValue);
        if (formats.isNotEmpty) {
          final Map<String, dynamic> placeholders = {};
          for (final f in formats) {
            if (f.group(1) != null) {
              placeholders.putIfAbsent(f.group(1)!, () => <String, dynamic>{});
            }
          }
          newJson["@${entity.key}"] = <String, dynamic>{
            "placeholders": placeholders
          };
        }
      }
    }
    return newJson;
  }
}


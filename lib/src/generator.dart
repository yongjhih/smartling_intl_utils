import 'dart:convert';
import 'dart:io';

import 'package:smartling_intl_utils/smartling_intl_utils.dart';
import 'package:intl_utils/src/generator/generator.dart' as IntlUtils;
import 'package:intl_utils/src/config/pubspec_config.dart';
import 'package:intl_utils/src/constants/constants.dart';
import 'package:path/path.dart' as Path;

/// const defaultClassName = 'S';
/// const defaultMainLocale = 'en';
/// final defaultArbDir = join('lib', 'l10n');
/// final defaultOutputDir = join('lib', 'generated');
/// const defaultUseDeferredLoading = false;
/// const defaultUploadOverwrite = false;
/// const defaultUploadAsReviewed = false;
/// const defaultDownloadEmptyAs = 'empty';
/// const defaultOtaEnabled = false;

/// smartling json to arb to intl with intl_utils
class Generator {
  const Generator({
    this.missed = false,
  });

  final bool missed;

  Future<void> generate() async {
    final inputFiles = getSmartlingFiles("i18n");
    final pubspecConfig = PubspecConfig();
    final arbDir = pubspecConfig.arbDir ?? defaultArbDir;

    for (final inputFile in inputFiles) {
      if (Path.basenameWithoutExtension(inputFile.path) == "no-translation") {
        continue;
      }
      final outputFile =
      await File(Path.join(
        arbDir,
        "intl_${Path.basenameWithoutExtension(inputFile.path).replaceAll(RegExp(r'-'), "_")}.arb",
      )).create(recursive: true);
      final Map<String, dynamic> smartlingJson =
      Map.castFrom(jsonDecode(inputFile.readAsStringSync()));
      outputFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(smartlingJson.toArb()));
    }

    try {
      final generator = IntlUtils.Generator();
      generator.missed = missed;
      await generator.generateAsync();
    } catch (e) {}
  }
}


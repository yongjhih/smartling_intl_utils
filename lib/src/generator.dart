import 'package:smartling_intl_utils/smartling_intl_utils.dart';
import 'package:smartling_intl_utils/src/pubspec_config.dart';

/// smartling json to arb to intl with intl_utils
class Generator {
  Future<void> generate() async {
    final config = PubspecConfig();
    final files = getSmartlingFiles(config.inputDir);
    final locales = getLocalesFromFiles(files);
  }
}
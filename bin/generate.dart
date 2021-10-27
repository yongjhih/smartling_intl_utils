library smartling_intl_utils;

import 'package:smartling_intl_utils/smartling_intl_utils.dart';

Future<void> main(List<String> args) async {
  try {
    var generator = Generator();
    await generator.generate();
  } catch (e) {
    print('Failed to generate localization files.\n$e');
  }
}

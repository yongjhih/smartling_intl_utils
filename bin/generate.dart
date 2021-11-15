library smartling_intl_utils;

import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:smartling_intl_utils/smartling_intl_utils.dart';

Future<void> main(List<String> arguments) async {
  try {
    final argParser = args.ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'Print this usage information.',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag(
        'missed',
        help: 'Add missing translations',
        defaultsTo: true,
      );

    try {
      final argResults = argParser.parse(arguments);
      if (argResults['help'] == true) {
        stdout.writeln(argParser.usage);
        exit(0);
      }

      var generator = Generator(missed: argResults['missed'] == true);
      await generator.generate();
    } on args.ArgParserException catch (err) {
      // nothing
    }
  } catch (err) {
    stdout.writeln('Failed to generate localization files.\n$err');
  }
}

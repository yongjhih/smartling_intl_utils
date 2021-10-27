import 'dart:convert';
import 'dart:io';

import 'package:smartling_intl_utils/smartling_intl_utils.dart';
import 'package:smartling_intl_utils/src/pubspec_config.dart';
import 'package:intl_generator/extract_messages.dart';
import 'package:intl_generator/generate_localized.dart';
import 'package:intl_generator/src/directory_utils.dart';
import 'package:intl_generator/src/icu_parser.dart';
import 'package:intl_generator/src/intl_message.dart';
import 'package:path/path.dart' as path;

late Map<String, List<MainMessage>> messages;
const jsonDecoder = const JsonCodec();

/// smartling json to arb to intl with intl_utils
class Generator {
  Future<void> generate() async {
    final generation = MessageGeneration();
    final config = PubspecConfig();
    final jsonFiles = getSmartlingFiles(config.inputDir);
    final locales = getLocalesFromFiles(jsonFiles);
    final targetDir = '.';

    var messagesByLocale = <String, List<Map>>{};

    for (final file in jsonFiles) {
      loadData(file.path, messagesByLocale, generation);
    }

    messagesByLocale.forEach((locale, data) {
      generateLocaleFile(locale, data, targetDir, generation);
    });

    var mainImportFile = File(path.join(
        targetDir, '${generation.generatedFilePrefix}messages_all.dart'));
    mainImportFile.writeAsStringSync(generation.generateMainImportFile());
  }
}

void loadData(String filename, Map<String, List<Map>> messagesByLocale,
    MessageGeneration generation) {
  var file = File(filename);
  var src = file.readAsStringSync();
  var data = jsonDecoder.decode(src);
  var locale = data["@@locale"] ?? data["_locale"];
  if (locale == null) {
    // Get the locale from the end of the file name. This assumes that the file
    // name doesn't contain any underscores except to begin the language tag
    // and to separate language from country. Otherwise we can't tell if
    // my_file_fr.arb is locale "fr" or "file_fr".
    var name = path.basenameWithoutExtension(file.path);
    locale = name.split("_").skip(1).join("_");
    print("No @@locale or _locale field found in $name, "
        "assuming '$locale' based on the file name.");
  }
  messagesByLocale.putIfAbsent(locale, () => []).add(data);
  generation.allLocales.add(locale);
}

/// Create the file of generated code for a particular locale.
///
/// We read the ARB
/// data and create [BasicTranslatedMessage] instances from everything,
/// excluding only the special _locale attribute that we use to indicate the
/// locale. If that attribute is missing, we try to get the locale from the
/// last section of the file name. Each ARB file produces a Map of message
/// translations, and there can be multiple such maps in [localeData].
void generateLocaleFile(String locale, List<Map> localeData, String targetDir,
    MessageGeneration generation) {
  List<TranslatedMessage> translations = [];
  for (var jsonTranslations in localeData) {
    jsonTranslations.forEach((id, messageData) {
      TranslatedMessage? message = recreateIntlObjects(id, messageData);
      if (message != null) {
        translations.add(message);
      }
    });
  }
  generation.generateIndividualMessageFile(locale, translations, targetDir);
}


/// Regenerate the original IntlMessage objects from the given [data]. For
/// things that are messages, we expect [id] not to start with "@" and
/// [data] to be a String. For metadata we expect [id] to start with "@"
/// and [data] to be a Map or null. For metadata we return null.
BasicTranslatedMessage? recreateIntlObjects(String id, data) {
  if (id.startsWith("@")) return null;
  if (data == null) return null;
  var parsed = pluralAndGenderParser.parse(data).value;
  if (parsed is LiteralString && parsed.string.isEmpty) {
    parsed = plainParser.parse(data).value;
  }
  return new BasicTranslatedMessage(id, parsed);
}

/// A TranslatedMessage that just uses the name as the id and knows how to look
/// up its original messages in our [messages].
class BasicTranslatedMessage extends TranslatedMessage {
  BasicTranslatedMessage(String name, translated) : super(name, translated);

  List<MainMessage> get originalMessages => (super.originalMessages.isEmpty)
      ? _findOriginals()
      : super.originalMessages;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  List<MainMessage> _findOriginals() => originalMessages = [];
}

final pluralAndGenderParser = new IcuParser().message;
final plainParser = new IcuParser().nonIcuMessage;

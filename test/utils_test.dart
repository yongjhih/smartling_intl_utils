import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:test/test.dart';
import 'package:smartling_intl_utils/src/utils.dart';

void main() {
    test("test utils", () async {
        final files = getSmartlingFiles("test/i18n");
        expect(files, isNotEmpty);
        final locales = getLocalesFromFiles(files);
        expect(locales, isNotEmpty);
        expect(locales, ["en"]);
        expect(r'My App'.smartlingToArbFormat(), r'My App');
        expect(r'My {{%1s}} App'.smartlingToArbFormat(), r'My {s1} App');
        expect(r'My {{%1s}} {{%2s}} App'.smartlingToArbFormat(), 'My {s1} {s2} App');
        expect(r'My {{%2s}} {{%1s}} App'.smartlingToArbFormat(), 'My {s2} {s1} App');
        final Map<String, dynamic?> smartlingJson = Map.castFrom(jsonDecode(files.first.readAsStringSync()));
        expect(smartlingJson.toArb(placeholdersEnabled: false), equals(<String, String>{
            "app_name": "My App",
            "app_name_formatted": "My {s1} App",
            "app_name_formatted2": "My {s1} {s2} App",
            "app_name_formatted_reversed": "My {s2} {s1} App",
        }));
        expect(smartlingJson.toArb(), equals(<String, dynamic>{
            "app_name": "My App",
            "app_name_formatted": "My {s1} App",
            '@app_name_formatted': <String, dynamic>{
                "placeholders": {
                    "s1": {},
                },
            },
            "app_name_formatted2": "My {s1} {s2} App",
            '@app_name_formatted2': <String, dynamic>{
                "placeholders": {
                    "s1": {},
                    "s2": {},
                }
            },
            "app_name_formatted_reversed": "My {s2} {s1} App",
            '@app_name_formatted_reversed': <String, dynamic>{
                "placeholders": {
                    "s2": {},
                    "s1": {},
                }
            },
        }));
        expect("de-DK".replaceAll(RegExp(r'-'), "_"), "de_DK");
        //print(JsonEncoder.withIndent('  ').convert(smartlingJson.toArb()));
    });
}
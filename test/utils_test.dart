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
        expect(r'My {{%1s}} App'.smartlingToArbFormat(), r'My {{it1}} App');
        expect(r'My {{%1s}} {{%2s}} App'.smartlingToArbFormat(), 'My {{it1}} {{it2}} App');
        expect(r'My {{%2s}} {{%1s}} App'.smartlingToArbFormat(), 'My {{it2}} {{it1}} App');
        final Map<String, Map<String, dynamic>> smartlingJson = Map.castFrom(jsonDecode(files.first.readAsStringSync()));
        expect(smartlingJson.toArb(), equals(<String, String>{
            "app_name": "My App",
            "app_name_formatted": "My {{it1}} App",
            "app_name_formatted2": "My {{it1}} {{it2}} App",
            "app_name_formatted_reversed": "My {{it2}} {{it1}} App",
        }));
    });
}
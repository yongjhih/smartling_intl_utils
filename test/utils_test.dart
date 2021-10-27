import 'package:test/test.dart';
import 'package:smartling_intl_utils/src/utils.dart';

void main() {
    test("test utils", () async {
        final files = getSmartlingFiles("test/i18n");
        expect(files, isNotEmpty);
        final locales = getLocalesFromFiles(files);
        expect(locales, isNotEmpty);
        expect(locales, ["en"]);
    });
}

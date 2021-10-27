import 'dart:io';

import 'utils.dart';
import 'package:yaml/yaml.dart' as Yaml;
import 'package:path/path.dart' as Path;

class PubspecConfig {
  bool? _enabled;
  String? _className;
  String? _mainLocale;
  String? _inputDir;
  String? _outputDir;
  bool? _useDeferredLoading;

  PubspecConfig() {
    final pubspecYaml = Yaml.loadYaml(File(
        Path.join(Directory.current.path, 'pubspec.yaml')
    ).existsOrThrow().readAsStringSync());

    final config = pubspecYaml['smartling_intl'];
    if (config == null) {
      return;
    }

    _enabled = config['enabled'] is bool
        ? config['enabled']
        : null;
    _className = config['class_name'] is String
        ? config['class_name']
        : null;
    _mainLocale = config['main_locale'] is String
        ? config['main_locale']
        : null;
    _inputDir = config['input_dir'] is String
        ? config['input_dir']
        : null;
    _outputDir = config['output_dir'] is String
        ? config['output_dir']
        : null;
    _useDeferredLoading = config['use_deferred_loading'] is bool
        ? config['use_deferred_loading']
        : null;
  }

  bool get enabled => _enabled ?? true;

  String get className => _className ?? "S";

  String get mainLocale => _mainLocale ?? "en";

  String get inputDir => _inputDir ?? "i18n";

  String get outputDir => _outputDir ?? inputDir;

  bool get useDeferredLoading => _useDeferredLoading ?? false;
}
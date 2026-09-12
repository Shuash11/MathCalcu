import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package metadata declares exactly 1.12.8+8', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final versionLines = pubspec
        .where((line) => line.trimLeft().startsWith('version:'))
        .toList();

    expect(versionLines, equals(['version: 1.12.8+8']));
  });

  test('stale version sources are absent', () {
    final existingStaleSources = ['lib/version.dart', 'web/version.json']
        .where((path) => File(path).existsSync())
        .toList();

    expect(existingStaleSources, isEmpty);
  });

  test('production Dart and web files do not consume stale version sources',
      () {
    final productionFiles = [
      ...Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')),
      ...Directory('web').listSync(recursive: true).whereType<File>(),
    ];

    for (final forbiddenReference in ['kAppVersion', 'version.json']) {
      final consumers = productionFiles
          .where(
            (file) => String.fromCharCodes(file.readAsBytesSync())
                .contains(forbiddenReference),
          )
          .map((file) => file.path)
          .toList();

      expect(consumers, isEmpty,
          reason: '$forbiddenReference must not be used');
    }
  });
}

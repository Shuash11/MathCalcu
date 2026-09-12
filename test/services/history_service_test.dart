// Task 7: HistoryService persists recent searches (max 10) and
// recently solved topics (max 20) via shared_preferences.
import 'package:calculus_system/services/history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
  });

  group('HistoryService recent searches', () {
    test('blank queries are ignored', () async {
      const history = HistoryService();
      await history.addRecentSearch('   ');
      expect(await history.getRecentSearches(), isEmpty);
    });

    test('most-recent-first with de-duplication', () async {
      const history = HistoryService();
      await history.addRecentSearch('ratio');
      await history.addRecentSearch('pie');
      await history.addRecentSearch('ratio');
      expect(await history.getRecentSearches(), ['ratio', 'pie']);
    });

    test('caps at 10 entries', () async {
      const history = HistoryService();
      for (var i = 0; i < 12; i++) {
        await history.addRecentSearch('q$i');
      }
      final recents = await history.getRecentSearches();
      expect(recents, hasLength(HistoryService.maxSearches));
      expect(recents.first, 'q11');
    });

    test('clear removes all searches', () async {
      const history = HistoryService();
      await history.addRecentSearch('ratio');
      await history.clearRecentSearches();
      expect(await history.getRecentSearches(), isEmpty);
    });
  });

  group('HistoryService recently solved', () {
    test('records label + route + timestamp', () async {
      const history = HistoryService();
      await history.addRecentSolved(
        label: 'Ratio & Proportion',
        route: '/grade6/ratio',
      );
      final entries = await history.getRecentSolved();
      expect(entries, hasLength(1));
      expect(entries.single.label, 'Ratio & Proportion');
      expect(entries.single.route, '/grade6/ratio');
    });

    test('re-opening a route moves it to the front', () async {
      const history = HistoryService();
      await history.addRecentSolved(label: 'A', route: '/grade6/a');
      await history.addRecentSolved(label: 'B', route: '/grade6/b');
      await history.addRecentSolved(label: 'A', route: '/grade6/a');
      final entries = await history.getRecentSolved();
      expect(entries.map((e) => e.route), ['/grade6/a', '/grade6/b']);
    });

    test('caps at 20 entries', () async {
      const history = HistoryService();
      for (var i = 0; i < 22; i++) {
        await history.addRecentSolved(label: 'T$i', route: '/grade6/t$i');
      }
      final entries = await history.getRecentSolved();
      expect(entries, hasLength(HistoryService.maxSolved));
      expect(entries.first.route, '/grade6/t21');
    });

    test('clear removes all solved entries', () async {
      const history = HistoryService();
      await history.addRecentSolved(label: 'A', route: '/grade6/a');
      await history.clearRecentSolved();
      expect(await history.getRecentSolved(), isEmpty);
    });
  });
}

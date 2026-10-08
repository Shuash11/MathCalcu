import 'package:calculus_system/core/curriculum_registry.dart';
import 'package:calculus_system/search/unified_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnifiedSearch route dedupe', () {
    test('proven collisions resolve to one row each', () {
      for (final q in ['circle', 'slope', 'derivative', 'limit']) {
        final routes = UnifiedSearch.search(q).map((h) => h.route).toList();
        expect(routes.length, routes.toSet().length, reason: q);
      }
    });
    test('curriculum hit wins for the collision route', () {
      final hits = UnifiedSearch.search('derivative');
      final row = hits.firstWhere((h) => h.route == '/topics/calculus/finals/derivatives');
      expect(row.curriculumTopic?.id, 'g12-derivatives');
    });
    test('curriculum hit already kept is not displaced by a later plain hit', () {
      const route = '/topics/calculus/finals/derivatives';
      final topic = CurriculumRegistry.getByRoute(route)!;
      final curriculumHit = UnifiedHit(
        label: topic.label,
        subtitle: topic.subtitle,
        route: route,
        icon: topic.icon,
        source: topic.gradeLevel,
        curriculumTopic: topic,
      );
      final plainHit = UnifiedHit(
        label: 'Plain finals hit',
        subtitle: 'same route, no curriculum topic',
        route: route,
        icon: topic.icon,
        source: 'Finals',
      );
      final kept = UnifiedSearch.dedupeByRoute([curriculumHit, plainHit]);
      expect(kept, hasLength(1));
      expect(kept.single.curriculumTopic, isNotNull);
      expect(kept.single.curriculumTopic?.id, 'g12-derivatives');
      expect(identical(kept.single, curriculumHit), isTrue);
    });
    test('regression guards unchanged', () {
      expect(UnifiedSearch.search(''), isEmpty);
      expect(UnifiedSearch.search('zzzz_no_such_topic_xyz'), isEmpty);
      expect(UnifiedSearch.search('slope').map((h) => h.source), contains('Midterm'));
    });
  });
}

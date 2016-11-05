library immutable.test.immutable_map_builder;

import 'package:immutable/immutable.dart';
import 'package:quiver_iterables/iterables.dart' show range;
import 'package:test/test.dart';

void main() {
  group('ImmutableMapBuilderTest', () {
    test('empty builder', () {
      final builder = new ImmutableMap<int, int>.empty().toBuilder();
      expect(builder.isEmpty, isTrue);
      expect(builder.length, 0);
    });

    test('add', () {
      final builder = new ImmutableMap<int, int>.empty().toBuilder();
      for (int i = 0; i < 1000; i += 2) {
        builder[i] = i;
      }
      expect(builder.length, 500);

      for (int i = 0; i < 1000; i += 2) {
        expect(builder.containsKey(i), isTrue);
        expect(builder[i], i);
      }

      final map = builder.toImmutable();
      for (int i = 0; i < 1000; i += 2) {
        expect(map.containsKey(i), isTrue);
        expect(map[i], i);
      }
    });

    test('remove', () {
      final builder = new ImmutableMap<int, int>.fromIterables(
          range(0, 1000), range(0, 1000)).toBuilder();
      for (int i = 1; i < 1000; i += 2) {
        expect(builder.remove(i), i);
      }

      expect(builder.length, 500);

      for (int i = 0; i < 1000; i += 2) {
        expect(builder.containsKey(i), isTrue);
        expect(builder[i], i);
      }
      for (int i = 1; i <= 1000; i += 2) {
        expect(builder.containsKey(i), isFalse);
        expect(builder[i], null);
      }

      final map = builder.toImmutable();
      for (int i = 0; i < 1000; i += 2) {
        expect(map.containsKey(i), isTrue);
        expect(map[i], i);
      }
      for (int i = 1; i <= 1000; i += 2) {
        expect(map.containsKey(i), isFalse);
        expect(map[i], null);
      }
    });

    test('reuse builder after toImmutable', () {
      final builder = new ImmutableMap<int, int>.empty().toBuilder();
      for (int i = 0; i < 1000; i += 2) {
        builder[i] = i;
      }
      final map = builder.toImmutable();
      for (int i = 0; i < 1000; i += 2) {
        builder[i] = i * 2;
      }

      for (int i = 0; i < 1000; i += 2) {
        expect(builder.containsKey(i), isTrue);
        expect(builder[i], i * 2);
      }
      for (int i = 0; i < 1000; i += 2) {
        expect(map.containsKey(i), isTrue);
        expect(map[i], i);
      }
    });
  });
}

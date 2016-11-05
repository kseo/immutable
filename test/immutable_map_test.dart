library immutable.test.immutable_map;

import 'package:immutable/immutable.dart';
import 'package:quiver_iterables/iterables.dart' show range;
import 'package:test/test.dart';

void main() {
  group('ImmutableMapTest', () {
    test('empty test', () {
      final empty = new ImmutableMap<int, int>.empty();
      expect(new ImmutableMap<int, int>.empty(), same(empty));
      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);
      expect(empty.length, 0);
    });

    test('fromIterable test', () {
      var map = new ImmutableMap<int, int>.fromIterable(range(0, 100));
      expect(map.length, 100);
      expect(map.keys, unorderedEquals(range(0, 100)));
      expect(map.values, unorderedEquals(range(0, 100)));

      map = new ImmutableMap<int, int>.fromIterable(range(0, 100),
          key: (k) => k + 100, value: (v) => v + 200);
      expect(map.length, 100);
      expect(map.keys, unorderedEquals(range(100, 200)));
      expect(map.values, unorderedEquals(range(200, 300)));
    });

    test('fromIterables test', () {
      var map = new ImmutableMap<int, int>.fromIterables(
          range(0, 1000), range(0, 1000));
      expect(map.length, 1000);
    });

    test('add', () {
      var map = new ImmutableMap<int, int>.empty();
      for (int i = 0; i < 1000; i += 2) {
        map = map.add(i, i);
      }
      expect(map.length, 500);

      for (int i = 0; i < 1000; i += 2) {
        expect(map.containsKey(i), isTrue);
        expect(map[i], i);
      }

      for (int i = 1; i <= 1000; i += 2) {
        expect(map.containsKey(i), isFalse);
        expect(map[i], null);
      }
    });

    test('remove', () {
      var map = new ImmutableMap<int, int>.fromIterables(
          range(0, 1000), range(0, 1000));
      for (int i = 1; i < 1000; i += 2) {
        map = map.remove(i);
      }

      expect(map.length, 500);

      for (int i = 0; i < 1000; i += 2) {
        expect(map.containsKey(i), isTrue);
        expect(map[i], i);
      }

      for (int i = 1; i <= 1000; i += 2) {
        expect(map.containsKey(i), isFalse);
        expect(map[i], null);
      }
    });

    test('hash collision keys', () {
      var map = new ImmutableMap<TestKey, int>.empty();
      final keys = new Iterable.generate(1000, (i) => new TestKey(i));

      for (final key in keys) {
        map = map.add(key, key.value);
      }

      expect(map.length, 1000);
      for (final key in keys) {
        expect(map.containsKey(key), isTrue);
        expect(map[key], key.value);
      }
    });
  });
}

class TestKey {
  final int value;

  TestKey(this.value);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(other) => other is TestKey && value == other.value;
}

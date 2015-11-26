library immutable.test.immutable_hash_map;

import 'package:immutable/immutable.dart';
import 'package:test/test.dart';

ImmutableMap<int, bool> createEmpty() =>
    new ImmutableHashMap<int, bool>.empty();

void emptyTestHelper(ImmutableMap<int, bool> empty, int someKey) {
  expect(empty.clear(), same(empty));
  expect(empty.length, equals(0));
  expect(empty.keys.length, equals(0));
  expect(empty.values.length, equals(0));
  expect(empty.containsKey(someKey), isFalse);
  expect(empty[someKey], isNull);
}

void containsKeyTestHelper(ImmutableMap<int, bool> map, int key, bool value) {
  expect(map.containsKey(key), isFalse);
  expect(map.add(key, value).containsKey(key), isTrue);
}

void iteratorTestHelper(ImmutableMap<int, bool> map) {
  for (int i = 0; i < 10; i++) {
    map = addTestHelper(map, i, false);
  }

  int j = 0;
  for (final key in map.keys) {
    expect(key, equals(j));
    j++;
  }
  for (final value in map.values) {
    expect(value, isFalse);
  }
}

ImmutableMap<int, bool> addTestHelper(
    ImmutableMap<int, bool> map, int key, bool value) {
  final addedMap = map.add(key, value);
  expect(addedMap, isNot(same(map)));
  expect(map.containsKey(key), isFalse);
  expect(addedMap.containsKey(key), isTrue);
  expect(addedMap[key], same(value));
  return addedMap;
}

void removeTestHelper(ImmutableMap<int, bool> map, int key) {
  expect(map.remove(key), same(map));

  final addedMap = map.add(key, false);
  final removedMap = addedMap.remove(key);
  expect(removedMap, isNot(same(addedMap)));
  expect(removedMap.containsKey(key), isFalse);
}

void addAscendingTestHelper(ImmutableMap<int, bool> map) {
  for (int i = 0; i < 10; i++) {
    map = addTestHelper(map, i, false);
  }

  expect(map.length, equals(10));
  for (int i = 0; i < 10; i++) {
    expect(map.containsKey(i), isTrue);
  }
}

void addDescendingTestHelper(ImmutableMap<int, bool> map) {
  for (int i = 10; i > 0; i--) {
    map = addTestHelper(map, i, false);
  }

  expect(map.length, equals(10));
  for (int i = 10; i > 0; i--) {
    expect(map.containsKey(i), isTrue);
  }
}

void keysTestHelper(ImmutableMap<int, bool> map, int key) {
  expect(map.keys.length, equals(0));

  final nonEmpty = map.add(key, false);
  expect(nonEmpty.keys.length, equals(1));
}

void valuesTestHelper(ImmutableMap<int, bool> map, int key) {
  expect(map.values.length, equals(0));

  final nonEmpty = map.add(key, false);
  expect(nonEmpty.values.length, equals(1));
}

/// Verifies that adding a key-value pair where the key already is
/// in the map but with a different value overwrites the old value.
void addExistingKeyDifferentValueTestHelper(
    ImmutableMap<int, bool> map, int key) {
  map = map.add(key, false);
  map = map.add(key, true);

  expect(map[key], isTrue);
}

void main() {
  group('ImmutableHashMapTest', () {
    test('empty test', () {
      emptyTestHelper(createEmpty(), 5);
    });

    test('containsKey', () {
      containsKeyTestHelper(createEmpty(), 5, false);
    });

    test('index get', () {
      final map = createEmpty().add(5, false);
      expect(map[5], isFalse);
    });

    test('add ascending', () {
      addAscendingTestHelper(createEmpty());
    });

    test('add descending', () {
      addDescendingTestHelper(createEmpty());
    });

    test('iterator', () {
      iteratorTestHelper(createEmpty());
    });

    test('remove', () {
      removeTestHelper(createEmpty(), 5);
    });

    test('keys', () {
      keysTestHelper(createEmpty(), 5);
    });

    test('values', () {
      valuesTestHelper(createEmpty(), 5);
    });

    test('addExistingKeyDifferentValueTest', () {
      addExistingKeyDifferentValueTestHelper(createEmpty(), 5);
    });
  });
}

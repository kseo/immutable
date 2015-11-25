library immutable.test.immutable_list_builder;

import 'package:immutable/immutable.dart';
import 'package:quiver_iterables/iterables.dart' show range;
import 'package:test/test.dart';

void main() {
  group('ImmutableListBuilderTest', () {
    test('create builder', () {
      final builder = new ImmutableListBuilder<String>.empty();
      expect(builder, isNotNull);
    });

    test('toBuilder', () {
      final builder = new ImmutableList<int>.empty().toBuilder();
      builder.add(3);
      builder.add(5);
      builder.add(5);
      expect(builder.length, equals(3));
      expect(builder.contains(3), isTrue);
      expect(builder.contains(5), isTrue);
      expect(builder.contains(7), isFalse);

      final list = builder.toImmutable();
      expect(list.length, equals(3));
      builder.add(8);
      expect(builder.length, equals(4));
      expect(list.length, equals(3));
      expect(builder.contains(8), isTrue);
      expect(list.contains(8), isFalse);
    });

    test('builder from list', () {
      final list = new ImmutableList<int>.empty().add(1);
      final builder = list.toBuilder();
      builder.add(3);
      builder.add(5);
      builder.add(5);
      expect(builder.length, equals(4));
      expect(builder.contains(3), isTrue);
      expect(builder.contains(5), isTrue);
      expect(builder.contains(7), isFalse);

      final list2 = builder.toImmutable();
      expect(list2.length, equals(builder.length));
      expect(list2.contains(1), isTrue);
      builder.add(8);
      expect(builder.length, equals(5));
      expect(list2.length, equals(4));
      expect(builder.contains(8), isTrue);

      expect(list.contains(8), isFalse);
      expect(list2.contains(8), isFalse);
    });

    test('several changes', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();
      final immutable1 = mutable.toImmutable();
      expect(immutable1, same(mutable.toImmutable()));

      mutable.add(2);
      final immutable2 = mutable.toImmutable();
      expect(immutable1, isNot(same(immutable2)));
      expect(mutable.toImmutable(), same(immutable2));
      expect(immutable2.length, equals(1));
    });

    test('iterate builder while mutating', () {
      final builder = new ImmutableList<int>.empty().addAll(range(1, 11)).toBuilder();
      expect(builder, range(1, 11).toList());

      final iterator = builder.iterator;
      expect(iterator.moveNext(), isTrue);
      builder.add(11);

      // Verify that a new iterator will succeed.
      expect(builder, range(1, 12).toList());

      // Try iterating further with the previous iterable now that
      // we've changed the collection.
      expect(() => iterator.moveNext(), throwsConcurrentModificationError);

      // Verify that by obtaining a new iterator,
      // we can iterate all the contents.
      expect(builder, range(1, 12).toList());
    });

    test('builder reuses unchanged immutable instances', () {
      final collection = new ImmutableList<int>.empty().add(1);
      final builder = collection.toBuilder();
      expect(builder.toImmutable(), same(collection));
      builder.add(2);

      final newImmutable = builder.toImmutable();
      expect(newImmutable, isNot(same(collection)));
      expect(builder.toImmutable(), same(newImmutable));
    });

    test('insert', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();
      mutable.insert(0, 1);
      mutable.insert(0, 0);
      mutable.insert(2, 3);
      expect(mutable, orderedEquals([0, 1, 3]));

      expect(() => mutable.insert(-1, 0), throwsRangeError);
      expect(() => mutable.insert(4, 0), throwsRangeError);
    });

    test('insertAll', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();
      mutable.insertAll(0, [1, 4, 5]);
      expect(mutable, orderedEquals([1, 4, 5]));
      mutable.insertAll(1, [2, 3]);
      expect(mutable, orderedEquals([1, 2, 3, 4, 5]));
      mutable.insertAll(5, [6]);
      expect(mutable, orderedEquals([1, 2, 3, 4, 5, 6]));
      mutable.insertAll(5, []);
      expect(mutable, orderedEquals([1, 2, 3, 4, 5, 6]));

      expect(() => mutable.insertAll(-1, []), throwsRangeError);
      expect(() => mutable.insertAll(mutable.length + 1, []), throwsRangeError);
    });

    test('addAll', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();
      mutable.addAll([1, 4, 5]);
      expect(mutable, orderedEquals([1, 4, 5]));
      mutable.addAll([2, 3]);
      expect(mutable, orderedEquals([1, 4, 5, 2, 3]));
      mutable.addAll([]);
      expect(mutable, orderedEquals([1, 4, 5, 2, 3]));

      expect(() => mutable.addAll(null), throwsArgumentError);
    });

    test('remove', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();
      expect(mutable.remove(5), isFalse);

      mutable.add(1);
      mutable.add(2);
      mutable.add(3);
      expect(mutable.remove(2), isTrue);
      expect(mutable, orderedEquals([1, 3]));
      expect(mutable.remove(1), isTrue);
      expect(mutable, [3]);
      expect(mutable.remove(3), isTrue);
      expect(mutable, []);

      expect(mutable.remove(5), isFalse);
    });

    test('removeAt', () {
      final mutable = new ImmutableList<int>.empty().toBuilder();

      mutable.add(1);
      mutable.add(2);
      mutable.add(3);
      mutable.removeAt(2);
      expect(mutable, orderedEquals([1, 2]));
      mutable.removeAt(0);
      expect(mutable, [2]);

      expect(() => mutable.removeAt(1), throwsRangeError);

      mutable.removeAt(0);
      expect(mutable, []);

      expect(() => mutable.removeAt(0), throwsRangeError);
      expect(() => mutable.removeAt(-1), throwsRangeError);
      expect(() => mutable.removeAt(1), throwsRangeError);
    });

    test('reversed', () {
      final mutable = new ImmutableList.from(range(1, 4)).toBuilder();
      expect(mutable.reversed, range(1, 4).toList().reversed);
    });

    test('clear', () {
      final mutable = new ImmutableList.from(range(1, 4)).toBuilder();
      mutable.clear();
      expect(mutable.length, equals(0));

      // Do it again for good measure. :)
      mutable.clear();
      expect(mutable.length, equals(0));
    });

    test('indexer', () {
      final mutable = new ImmutableList.from(range(1, 4)).toBuilder();
      expect(mutable[1], equals(2));
      mutable[1] = 5;
      expect(mutable[1], equals(5));
      mutable[0] = -2;
      mutable[2] = -3;
      expect(mutable, orderedEquals([-2, 5, -3]));

      expect(() => mutable[3] = 4, throwsRangeError);
      expect(() => mutable[-1] = 4, throwsRangeError);
      expect(() => mutable[3], throwsRangeError);
      expect(() => mutable[-1], throwsRangeError);
    });

    test('iterator explicit', () {
      final builder = new ImmutableList<int>.empty().toBuilder();
      final iterator = builder.iterator;
      expect(iterator, isNotNull);
    });
  });
}

library immutable.test.immutable_list;

import 'package:immutable/immutable.dart';
import 'package:quiver_iterables/iterables.dart' show range;
import 'package:test/test.dart';

void main() {
  group('ImmutableListTest', () {
    test('empty test', () {
      final empty = new ImmutableList<int>.empty();
      expect(new ImmutableList<int>.empty(), same(empty));
      expect(empty.clear(), same(empty));
      expect(empty.isEmpty, isTrue);
      expect(empty.length, equals(0));
      expect(empty.indexOf(null), -1);
    });

    test('add and indexer', () {
      var list = new ImmutableList<int>.empty();
      for (int i = 1; i <= 10; i++) {
        list = list.add(i * 10);
        expect(list.isEmpty, isFalse);
        expect(list.length, i);
      }

      for (int i = 1; i <= 10; i++) {
        expect(list[i - 1], equals(i * 10));
      }

      var bulkList =
          new ImmutableList<int>.empty().addAll(range(1, 11).map((i) => i * 10));
      expect(bulkList, equals(list));
    });

    test('addAll', () {
      var list = new ImmutableList<int>.empty();
      list = list.addAll([1, 2, 3]);
      list = list.addAll(range(4, 6));
      list = list.addAll(new ImmutableList<int>.empty().addAll([6, 7, 8]));
      list = list.addAll([]);
      list = list.addAll(new ImmutableList<int>.empty().addAll(range(9, 1009)));
      expect(list, range(1, 1009).toList());
    });

    test('insert', () {
      var list = new ImmutableList<int>.empty();
      expect(() => list.insert(1, 5), throwsRangeError);
      expect(() => list.insert(-1, 5), throwsRangeError);

      list = list.insert(0, 10);
      list = list.insert(1, 20);
      list = list.insert(2, 30);

      list = list.insert(2, 25);
      list = list.insert(1, 15);
      list = list.insert(0, 5);

      expect(list.length, 6);
      expect(list, orderedEquals([5, 10, 15, 20, 25, 30]));

      expect(() => list.insert(7, 5), throwsRangeError);
      expect(() => list.insert(-1, 5), throwsRangeError);
    });

    test('insertAll', () {
      var list = new ImmutableList<int>.empty();
      list = list.insertAll(0, [1, 4, 5]);
      expect(list, orderedEquals([1, 4, 5]));
      list = list.insertAll(1, [2, 3]);
      expect(list, orderedEquals([1, 2, 3, 4, 5]));
      list = list.insertAll(5, [6]);
      expect(list, orderedEquals([1, 2, 3, 4, 5, 6]));
      list = list.insertAll(5, []);
      expect(list, orderedEquals([1, 2, 3, 4, 5, 6]));

      expect(() => list.insertAll(-1, []), throwsRangeError);
      expect(() => list.insertAll(list.length + 1, []), throwsRangeError);
    });

    test('remove', () {
      var list = new ImmutableList<int>.empty();
      for (int i = 1; i <= 10; i++) {
        list = list.add(i * 10);
      }

      list = list.remove(30);
      expect(list.length, equals(9));
      expect(list.contains(30), isFalse);

      list = list.remove(100);
      expect(list.length, equals(8));
      expect(list.contains(100), isFalse);

      list = list.remove(10);
      expect(list.length, equals(7));
      expect(list.contains(10), isFalse);
    });

    test('remove non-existent keeps reference', () {
      final list = new ImmutableList<int>.empty();
      expect(list.remove(3), same(list));
    });

    test('removeAt', () {
      var list = new ImmutableList<int>.empty();
      expect(() => list.removeAt(0), throwsRangeError);
      expect(() => list.removeAt(-1), throwsRangeError);
      expect(() => list.removeAt(1), throwsRangeError);

      for (int i = 1; i <= 10; i++) {
        list = list.add(i * 10);
      }

      list = list.removeAt(2);
      expect(list.length, equals(9));
      expect(list.contains(30), isFalse);

      list = list.removeAt(8);
      expect(list.length, equals(8));
      expect(list.contains(100), isFalse);

      list = list.removeAt(0);
      expect(list.length, equals(7));
      expect(list.contains(10), isFalse);
    });

    test('indexOf and contains', () {
      final expectedList = [
        "Microsoft",
        "Windows",
        "Bing",
        "Visual Studio",
        "Comics",
        "Computers",
        "Laptops"
      ];

      var list = new ImmutableList<int>.empty();
      for (String newElement in expectedList) {
        expect(list.contains(newElement), isFalse);
        list = list.add(newElement);
        expect(list.contains(newElement), isTrue);
        expect(list.indexOf(newElement), expectedList.indexOf(newElement));
        expect(list.indexOf(newElement.toUpperCase()), -1);

        for (String existingElement
            in expectedList.takeWhile((v) => v != newElement)) {
          expect(list.contains(existingElement), isTrue);
          expect(list.indexOf(existingElement),
              expectedList.indexOf(existingElement));
          expect(list.indexOf(existingElement.toUpperCase()), -1);
        }
      }
    });

    test('indexer', () {
      final list = new ImmutableList.from(range(1, 4));
      expect(list[0], equals(1));
      expect(list[1], equals(2));
      expect(list[2], equals(3));

      expect(() => list[3], throwsRangeError);
      expect(() => list[-1], throwsRangeError);
    });

    test('indexOf', () {
      // FIXME: Check range.
      final emptyList = new ImmutableList<int>.empty();
      final list = new ImmutableList.from([1, 2, 5, 6]);

      expect(emptyList.indexOf(5), equals(-1));
      expect(emptyList.indexOf(5, 0), equals(-1));
      expect(list.indexOf(5), equals(2));
      expect(list.indexOf(5, 1), equals(2));
    });

    test('lastIndexOf', () {
      // FIXME: Check range.
      final emptyList = new ImmutableList<int>.empty();
      final list = new ImmutableList.from([1, 2, 5, 6]);

      expect(emptyList.lastIndexOf(5), equals(-1));
      expect(emptyList.lastIndexOf(5, 0), equals(-1));
      expect(list.lastIndexOf(5), equals(2));
      expect(list.lastIndexOf(5, 1), equals(-1));
    });

    test('equals', () {});

    test('create', () {
      var list = new ImmutableList<String>.empty();
      expect(list.length, 0);

      list = new ImmutableList<String>.empty().add('a');
      expect(list.length, 1);

      list = new ImmutableList.from(['a', 'b']);
      expect(list.length, 2);
    });

    test('iterator', () {
      final list = new ImmutableList<String>.empty().add('a');
      final iterator = list.iterator;
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals('a'));
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
    });

    test('setItem', () {
      final emptyList = new ImmutableList<int>.empty();
      expect(() => emptyList[-1], throwsRangeError);
      expect(() => emptyList[0], throwsRangeError);
      expect(() => emptyList[1], throwsRangeError);

      final listOfOne = emptyList.add(5);
      expect(() => listOfOne[-1], throwsRangeError);
      expect(listOfOne[0], equals(5));
      expect(() => listOfOne[1], throwsRangeError);
    });

    test('subList', () {
      var list = new ImmutableList.from([1, 2, 5, 6]);

      expect(list.sublist(1), orderedEquals([2, 5, 6]));
      expect(list.sublist(1, 3), orderedEquals([2, 5]));
    });

    test('getRange', () {
      var list = new ImmutableList.from([1, 2, 5, 6]);

      expect(list.getRange(1, 3), orderedEquals([2, 5]));
    });

    test('removeWhere/retainWhere', () {
      final isEven = (int e) => e % 2 == 0;

      final emptyList = new ImmutableList<int>.empty();
      expect(emptyList.removeWhere(isEven), same(emptyList));
      expect(emptyList.retainWhere(isEven), same(emptyList));

      final list = new ImmutableList.from([1, 2, 5, 6]);
      expect(list.removeWhere(isEven), orderedEquals([1, 5]));
      expect(list.retainWhere(isEven), orderedEquals([2, 6]));
    });

    test('firstWhere/lastWhere', () {
      final isEven = (int e) => e % 2 == 0;

      final emptyList = new ImmutableList<int>.empty();
      expect(() => emptyList.firstWhere(isEven), throwsStateError);
      expect(() => emptyList.lastWhere(isEven), throwsStateError);

      final list = new ImmutableList.from([1, 2, 5, 6]);
      expect(list.firstWhere(isEven), equals(2));
      expect(list.lastWhere(isEven), equals(6));
    });

    test('take/skip', () {
      final emptyList = new ImmutableList<int>.empty();
      expect(emptyList.take(2), []);
      expect(emptyList.skip(2), []);

      final list = new ImmutableList.from([1, 2, 5, 6]);
      expect(list.take(2), orderedEquals([1, 2]));
      expect(list.skip(2), orderedEquals([5, 6]));
    });

    test('removeLast', () {
      final emptyList = new ImmutableList<int>.empty();
      expect(() => emptyList.removeLast(), throwsRangeError);

      var list = new ImmutableList.from([1, 2, 5, 6]);
      list = list.removeLast();

      expect(list.length, equals(3));
      expect(list.contains(6), isFalse);
      expect(list, orderedEquals([1, 2, 5]));
    });

    test('fillRange', () {
      final emptyList = new ImmutableList<int>.empty();
      expect(() => emptyList.fillRange(1, 3), throwsRangeError);

      var list = new ImmutableList.from([1, 2, 5, 6]);

      expect(list.fillRange(1, 3), orderedEquals([1, null, null, 6]));
      expect(list.fillRange(1, 3, 4), orderedEquals([1, 4, 4, 6]));
    });

    test('setRange', () {
      final list = new ImmutableList.from([1, 2, 3, 4]);
      final other = [5, 6, 7, 8, 9];
      expect(list.setRange(1, 3, other, 3), orderedEquals([1, 8, 9, 4]));
    });

    test('setAll', () {
      final list = new ImmutableList.from([1, 2, 3]);

      expect(list.setAll(1, [4, 5]), orderedEquals([1, 4, 5]));
    });

    test('replaceRange', () {
      final list = new ImmutableList.from([1, 2, 3, 4, 5]);
      expect(list.replaceRange(1, 4, []), orderedEquals([1, 5]));
      expect(list.replaceRange(1, 4, [6, 7]), orderedEquals([1, 6, 7, 5]));
      expect(list.replaceRange(1, 4, [6, 7, 8, 9, 10]),
          orderedEquals([1, 6, 7, 8, 9, 10, 5]));
    });
  });
}

library immutable.test.immutable_queue;

import 'package:immutable/immutable.dart';
import 'package:test/test.dart';

void main() {
  group('ImmutableQueueTest', () {
    test('iteration order', () {
      var queue = new ImmutableQueue<int>.empty();

      // Push elements onto the backwards stack.
      queue = queue.enqueue(1).enqueue(2).enqueue(3);
      expect(queue.peek(), equals(1));

      // Force the backwards stack to be reversed and put into forwards.
      queue = queue.dequeue();

      // Push elements onto the backwards stack again.
      queue = queue.enqueue(4).enqueue(5);

      // Now that we have some elements on the forwards and backwards stack,
      // 1. enumerate all elements to verify order.
      expect(queue, orderedEquals([2, 3, 4, 5]));

      // 2. dequeue all elements to verify order
      final actual = new List(queue.length);
      for (int i = 0; i < actual.length; i++) {
        actual[i] = queue.peek();
        queue = queue.dequeue();
      }
    });

    test('iterator', () {
      final queue = new ImmutableQueue<int>.empty().enqueue(5);
      final iterator = queue.iterator;
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(5));
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
    });

    test('enqueue/dequeue', () {
      final items = [1, 2, 3];
      var queue = new ImmutableQueue<int>.empty();
      int i = 0;
      for (final item in items) {
        final nextQueue = queue.enqueue(item);
        expect(nextQueue, isNot(same(queue)));
        expect(queue.length, i);
        expect(nextQueue.length, ++i);
        queue = nextQueue;
      }

      i = 0;
      for (final element in queue) {
        expect(element, same(items[i++]));
      }

      i = items.length;
      for (final expectedItem in items) {
        final actualItem = queue.peek();
        expect(actualItem, same(expectedItem));
        final nextQueue = queue.dequeue();
        expect(nextQueue, isNot(same(queue)));
        expect(queue.length, i);
        expect(nextQueue.length, --i);
        queue = nextQueue;
      }
    });

    test('clear', () {
      final emptyQueue = new ImmutableQueue<int>.empty();
      expect(emptyQueue.clear(), same(emptyQueue));
      final nonEmptyQueue = emptyQueue.enqueue(3);
      expect(nonEmptyQueue.clear(), same(emptyQueue));
    });

    test('equality', () {
      expect(new ImmutableQueue<int>.empty(), isNotNull);
      expect(new ImmutableQueue<int>.empty(), isNot(equals('hi')));
      expect(new ImmutableQueue<int>.empty(),
          equals(new ImmutableQueue<int>.empty()));
      expect(new ImmutableQueue<int>.empty().enqueue(3),
          equals(new ImmutableQueue<int>.empty().enqueue(3)));
      expect(new ImmutableQueue<int>.empty().enqueue(5),
          isNot(equals(new ImmutableQueue<int>.empty().enqueue(3))));
      expect(new ImmutableQueue<int>.empty().enqueue(3).enqueue(5),
          isNot(equals(new ImmutableQueue<int>.empty().enqueue(3))));
      expect(new ImmutableQueue<int>.empty().enqueue(3),
          isNot(equals(new ImmutableQueue<int>.empty().enqueue(3).enqueue(5))));

      expect(
          new ImmutableQueue<int>.empty()
              .enqueue(3)
              .enqueue(1)
              .enqueue(2)
              .dequeue(),
          equals(new ImmutableQueue<int>.empty().enqueue(1).enqueue(2)));
    });

    test('empty peek throws', () {
      expect(() => new ImmutableQueue<int>.empty().peek(), throwsStateError);
    });

    test('empty dequeue throws', () {
      expect(() => new ImmutableQueue<int>.empty().dequeue(), throwsStateError);
    });

    test('create', () {
      final queue = new ImmutableQueue.from([1, 2]);
      expect(queue.isEmpty, isFalse);
      expect(queue, orderedEquals([1, 2]));

      expect(() => new ImmutableQueue.from(null), throwsArgumentError);
    });
  });
}

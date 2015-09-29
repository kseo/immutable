library immutable.test.immutable_queue;

import 'package:immutable/immutable.dart';
import 'package:test/test.dart';

void main() {
  group('ImmutableQueueTest', () {
    test('iteration order', () {
      var queue = ImmutableQueue.empty;

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
      final queue = ImmutableQueue.empty.enqueue(5);
      final iterator = queue.iterator;
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(5));
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
    });

    test('enqueue/dequeue', () {
      final items = [1, 2, 3];
      var queue = ImmutableQueue.empty;
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
      final emptyQueue = ImmutableQueue.empty;
      expect(emptyQueue.clear(), same(emptyQueue));
      final nonEmptyQueue = emptyQueue.enqueue(3);
      expect(nonEmptyQueue.clear(), same(emptyQueue));
    });

    test('equality', () {
      expect(ImmutableQueue.empty, isNotNull);
      expect(ImmutableQueue.empty, isNot(equals('hi')));
      expect(ImmutableQueue.empty, equals(ImmutableQueue.empty));
      expect(ImmutableQueue.empty.enqueue(3),
          equals(ImmutableQueue.empty.enqueue(3)));
      expect(ImmutableQueue.empty.enqueue(5),
          isNot(equals(ImmutableQueue.empty.enqueue(3))));
      expect(ImmutableQueue.empty.enqueue(3).enqueue(5),
          isNot(equals(ImmutableQueue.empty.enqueue(3))));
      expect(ImmutableQueue.empty.enqueue(3),
          isNot(equals(ImmutableQueue.empty.enqueue(3).enqueue(5))));

      expect(ImmutableQueue.empty.enqueue(3).enqueue(1).enqueue(2).dequeue(),
          equals(ImmutableQueue.empty.enqueue(1).enqueue(2)));
    });

    test('empty peek throws', () {
      expect(() => ImmutableQueue.empty.peek(), throwsStateError);
    });

    test('empty dequeue throws', () {
      expect(() => ImmutableQueue.empty.dequeue(), throwsStateError);
    });

    test('create', () {
      final queue = new ImmutableQueue.from([1, 2]);
      expect(queue.isEmpty, isFalse);
      expect(queue, orderedEquals([1, 2]));

      expect(() => new ImmutableQueue.from(null), throwsArgumentError);
    });
  });
}

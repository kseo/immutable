library immutable.test.immutable_stack;

import 'package:immutable/immutable.dart';
import 'package:test/test.dart';

void main() {
  group('ImmutableStackTest', () {
    ImmutableStack<int> initStackHelper(Iterable<int> values) {
      var result = ImmutableStack.empty;
      for (final value in values) {
        result = result.push(value);
      }

      return result;
    }

    test('empty test', () {
      ImmutableStack<int> actual = ImmutableStack.empty;
      expect(actual, isNotNull);
      expect(actual.isEmpty, isTrue);
      expect(ImmutableStack.empty, same(actual.clear()));
      expect(ImmutableStack.empty, same(actual.push(1).clear()));
    });

    test('push and length', () {
      final actual0 = ImmutableStack.empty;
      expect(actual0.length, equals(0));
      final actual1 = actual0.push(1);
      expect(actual1.length, equals(1));
      expect(actual0.length, equals(0));
      final actual2 = actual1.push(2);
      expect(actual2.length, equals(2));
      expect(actual0.length, equals(0));
    });

    test('pop', () {
      final values = [1, 2, 3];
      final full = initStackHelper(values);
      var currentStack = full;

      for (int expectedLength = values.length;
          expectedLength > 0;
          expectedLength--) {
        expect(currentStack.length, equals(expectedLength));
        currentStack.pop();
        expect(currentStack.length, equals(expectedLength));
        final nextStack = currentStack.pop();
        expect(currentStack.length, equals(expectedLength));
        expect(currentStack, isNot(same(nextStack)));
        expect(currentStack.pop(), same(currentStack.pop()),
            reason:
                'Popping the stack 2X should yield the same shorter stack.');
        currentStack = nextStack;
      }
    });

    test('peek', () {
      final values = [1, 2, 3];
      var current = initStackHelper(values);
      for (int i = values.length - 1; i >= 0; i--) {
        expect(current.peek(), same(values[i]));
        var next = current.pop();
        expect(current.peek(), same(values[i]),
            reason: 'Pop mutated the stack instance.');
        current = next;
      }
    });

    void iteratorTestHelper(List<int> values) {
      final full = initStackHelper(values);

      int i = values.length - 1;
      for (final element in full) {
        expect(element, same(values[i--]));
      }

      expect(i, equals(-1));
    }

    test('iterator', () {
      iteratorTestHelper([1, 2, 3]);
      iteratorTestHelper([]);

      final stack = ImmutableStack.empty.push(5);
      final iterator = stack.iterator;
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(5));
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
    });

    test('equality', () {
      expect(ImmutableStack.empty, isNotNull);
      expect(ImmutableStack.empty, isNot(equals('hi')));
      expect(ImmutableStack.empty, equals(ImmutableStack.empty));
      expect(
          ImmutableStack.empty.push(3), equals(ImmutableStack.empty.push(3)));
      expect(ImmutableStack.empty.push(5),
          isNot(equals(ImmutableStack.empty.push(3))));
      expect(ImmutableStack.empty.push(3).push(5),
          isNot(equals(ImmutableStack.empty.push(3))));
      expect(ImmutableStack.empty.push(3),
          isNot(equals(ImmutableStack.empty.push(3).push(5))));
    });

    test('empty peek throws', () {
      expect(() => ImmutableStack.empty.peek(), throwsStateError);
    });

    test('empty pop throws', () {
      expect(() => ImmutableStack.empty.pop(), throwsStateError);
    });

    test('create', () {
      final stack = new ImmutableStack.from([1, 2]);
      expect(stack.isEmpty, isFalse);
      expect(stack, orderedEquals([2, 1]));

      expect(() => new ImmutableStack.from(null), throwsArgumentError);
    });
  });
}

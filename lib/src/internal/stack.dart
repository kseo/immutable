part of immutable._internal;

/// The [Stack] class represents a last-in-first-out (LIFO) stack of objects.
class Stack<E> extends IterableBase<E> {
  List<E> _items = <E>[];

  /// Inserts the given [item] at the top of the [Stack].
  void push(E item) {
    _items.add(item);
  }

  /// Removes and returns the object at the top of the [Stack].
  E pop() {
    if (_items.isEmpty) {
      throw new StateError('stack is empty');
    }
    return _items.removeLast();
  }

  /// Returns the object at the top of the [Stack] without removing it.
  E peek() => _items.last;

  /// Pop all the objects.
  void clear() {
    _items.clear();
  }

  @override
  Iterator<E> get iterator => _items.reversed.iterator;

  /// Returns the number of elements in the [Stack].
  @override
  int get length => _items.length;

  /// Returns `true` if there are no elements in the [Stack].
  @override
  bool get isEmpty => _items.isEmpty;

  /// Returns `true` if there is at least one element in the [Stack].
  @override
  bool get isNotEmpty => !isEmpty;
}
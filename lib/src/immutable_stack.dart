part of immutable;

abstract class ImmutableStack<E> implements Iterable<E> {
  /// Returns an empty collection.
  static final ImmutableStack empty = _ImmutableStack.empty;

  ///  Creates a new immutable collection prefilled with the specified [items].
  factory ImmutableStack.from(Iterable<E> items) {
    if (items == null) {
      throw new ArgumentError.notNull('items');
    }

    var stack = _ImmutableStack.empty;
    for (final item in items) {
      stack = stack.push(item);
    }

    return stack;
  }

  /// Gets an empty stack.
  ImmutableStack<E> clear();

  /// Pushes an element onto a stack and returns the new stack.
  ImmutableStack<E> push(E value);

  /// Pops the top element off the stack and returns the new stack.
  ///
  /// [StateError] is thrown when the stack is empty.
  ImmutableStack<E> pop();

  /// Gets the element on the top of the stack.
  ///
  /// [StateError] is thrown when the stack is empty.
  E peek();
}

class _ImmutableStack<E> extends IterableBase<E> implements ImmutableStack<E> {
  static final _ImmutableStack empty = new _ImmutableStack._();

  final E _head;
  final ImmutableStack<E> _tail;

  _ImmutableStack._(): _head = null, _tail = null;

  _ImmutableStack._from(E head, _ImmutableStack<E> tail)
      : _head = head,
        _tail = tail {
    if (tail == null) {
      throw new ArgumentError.notNull('tail');
    }
  }

  @override
  _ImmutableStack<E> clear() => empty;

  @override
  bool get isEmpty => _tail == null;

  @override
  E peek() {
    if (isEmpty) {
      throw new StateError('stack is empty');
    }

    return _head;
  }

  @override
  _ImmutableStack<E> push(E value) => new _ImmutableStack._from(value, this);

  @override
  _ImmutableStack<E> pop() {
    if (isEmpty) {
      throw new StateError('stack is empty');
    }

    return _tail;
  }

  Iterator<E> get iterator => new _ImmutableStackIterator(this);

  /// Reverses the order of a stack.
  ImmutableStack<E> _reverse() {
    var r = clear();
    for (ImmutableStack<E> f = this; f.isNotEmpty; f = f.pop()) {
      r = r.push(f.peek());
    }

    return r;
  }
}

/// Enumerates a stack with no memory allocations.
class _ImmutableStackIterator<E> implements Iterator<E> {
  /// The original stack being enumerated.
  final _ImmutableStack<E> _originalStack;

  /// The remaining stack not yet enumerated.
  _ImmutableStack<E> _remainingStack;

  _ImmutableStackIterator(_ImmutableStack<E> stack) : _originalStack = stack {
    if (stack == null) {
      throw new ArgumentError.notNull('stack');
    }
  }

  @override
  E get current {
    if (_remainingStack == null || _remainingStack.isEmpty) {
      return null;
    } else {
      return _remainingStack.peek();
    }
  }

  @override
  bool moveNext() {
    if (_remainingStack == null) {
      _remainingStack = _originalStack;
    } else if (!_remainingStack.isEmpty) {
      _remainingStack = _remainingStack.pop();
    }

    return !_remainingStack.isEmpty;
  }
}

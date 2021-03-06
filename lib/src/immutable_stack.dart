// Copyright (c) 2015, Kwang Yul Seo <kwangyul.seo@gmail.com>.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:quiver_check/check.dart';

class ImmutableStack<E> extends IterableBase<E> {
  static final ImmutableStack _empty = new ImmutableStack._internal(null, null);

  final E _head;
  final ImmutableStack<E> _tail;

  Iterator<E> get iterator => new _ImmutableStackIterator(this);

  /// Returns an empty collection.
  factory ImmutableStack.empty() => _empty as ImmutableStack<E>;

  ///  Creates a new immutable collection prefilled with the specified [items].
  factory ImmutableStack.from(Iterable<E> items) {
    checkNotNull(items);

    var stack = ImmutableStack._empty as ImmutableStack<E>;
    for (final item in items) {
      stack = stack.push(item);
    }

    return stack;
  }

  ImmutableStack._internal(E head, ImmutableStack<E> tail)
      : _head = head,
        _tail = tail;

  @override
  bool get isEmpty => _tail == null;

  /// Pushes an element onto a stack and returns the new stack.
  ImmutableStack<E> push(E value) => new ImmutableStack._internal(value, this);

  /// Pops the top element off the stack and returns the new stack.
  ///
  /// [StateError] is thrown when the stack is empty.
  ImmutableStack<E> pop() {
    if (isEmpty) throw new StateError('stack is empty');

    return _tail;
  }

  /// Gets the element on the top of the stack.
  ///
  /// [StateError] is thrown when the stack is empty.
  E peek() {
    if (isEmpty) throw new StateError('stack is empty');

    return _head;
  }

  /// Gets an empty stack.
  ImmutableStack<E> clear() => _empty as ImmutableStack<E>;
}

/// Enumerates a stack with no memory allocations.
class _ImmutableStackIterator<E> implements Iterator<E> {
  /// The original stack being enumerated.
  final ImmutableStack<E> _originalStack;

  /// The remaining stack not yet enumerated.
  ImmutableStack<E> _remainingStack;

  _ImmutableStackIterator(ImmutableStack<E> stack) : _originalStack = stack {
    checkNotNull(stack);
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

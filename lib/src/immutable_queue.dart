import 'dart:collection';

import 'package:quiver_check/check.dart';

import 'immutable_stack.dart';

class ImmutableQueue<E> extends IterableBase<E> {
  static final ImmutableQueue _empty = new ImmutableQueue._internal(
      new ImmutableStack.empty(), new ImmutableStack.empty());

  /// The end of the queue that enqueued elements are pushed onto.
  final ImmutableStack<E> _backwards;

  /// The end of the queue from which elements are dequeued.
  final ImmutableStack<E> _forwards;

  /// Backing field for the [backwardsReversed] property.
  ImmutableStack<E> _backwardsReversed;

  ImmutableStack<E> get backwardsReversed {
    if (_backwardsReversed == null)
      _backwardsReversed = _reverseStack(_backwards) as ImmutableStack<E>;

    return _backwardsReversed;
  }

  Iterator<E> get iterator => new _ImmutableQueueIterator(this);

  @override
  bool get isEmpty => _forwards.isEmpty && _backwards.isEmpty;

  /// Returns an empty collection.
  factory ImmutableQueue.empty() => _empty as ImmutableQueue<E>;

  ///  Creates a new immutable collection prefilled with the specified [items].
  factory ImmutableQueue.from(Iterable<E> items) {
    checkNotNull(items);

    var queue = new ImmutableQueue<E>.empty();
    for (final item in items) {
      queue = queue.enqueue(item);
    }

    return queue;
  }

  ImmutableQueue._internal(
      ImmutableStack<E> forwards, ImmutableStack<E> backwards)
      : _forwards = forwards,
        _backwards = backwards,
        _backwardsReversed = null {
    checkNotNull(forwards);
    checkNotNull(backwards);
  }

  /// Gets the empty queue.
  ImmutableQueue<E> clear() => _empty as ImmutableQueue<E>;

  /// Gets the element at the front of the queue.
  ///
  /// [StateError] is thrown when the queue is empty.
  E peek() {
    if (isEmpty) throw new StateError('queue empty');

    return _forwards.peek();
  }

  /// Adds an element to the back of the queue and returns a new queue.
  ImmutableQueue<E> enqueue(E value) {
    if (isEmpty) {
      return new ImmutableQueue<E>._internal(
          (new ImmutableStack<E>.empty()).push(value),
          new ImmutableStack<E>.empty());
    } else {
      return new ImmutableQueue<E>._internal(_forwards, _backwards.push(value));
    }
  }

  /// Returns a queue that is missing the front element.
  ///
  /// [StateError] is thrown when the queue is empty.
  ImmutableQueue<E> dequeue() {
    if (isEmpty) throw new StateError('queue empty');

    ImmutableStack<E> f = _forwards.pop();
    if (f.isNotEmpty) {
      return new ImmutableQueue<E>._internal(f, _backwards);
    } else if (_backwards.isEmpty) {
      return ImmutableQueue._empty as ImmutableQueue<E>;
    } else {
      return new ImmutableQueue<E>._internal(
          backwardsReversed, new ImmutableStack<E>.empty());
    }
  }
}

class _ImmutableQueueIterator<E> implements Iterator<E> {
  /// The original queue being enumerated.
  final ImmutableQueue<E> _originalQueue;

  /// The remaining forwards stack of the queue being enumerated.
  ImmutableStack<E> _remainingForwardsStack;

  /// The remaining backwards stack of the queue being enumerated.
  /// Its order is reversed when the field is first initialized.
  ImmutableStack<E> _remainingBackwardsStack;

  _ImmutableQueueIterator(this._originalQueue);

  @override
  E get current {
    if (_remainingForwardsStack == null) return null;

    if (_remainingForwardsStack.isNotEmpty) {
      return _remainingForwardsStack.peek();
    } else if (_remainingBackwardsStack.isNotEmpty) {
      return _remainingBackwardsStack.peek();
    } else {
      return null;
    }
  }

  @override
  bool moveNext() {
    if (_remainingForwardsStack == null) {
      // This is the initial step.
      // Empty queues have no forwards or backwards
      _remainingForwardsStack = _originalQueue._forwards;
      _remainingBackwardsStack = _originalQueue.backwardsReversed;
    } else if (_remainingForwardsStack.isNotEmpty) {
      _remainingForwardsStack = _remainingForwardsStack.pop();
    } else if (_remainingBackwardsStack.isNotEmpty) {
      _remainingBackwardsStack = _remainingBackwardsStack.pop();
    }

    return _remainingForwardsStack.isNotEmpty ||
        _remainingBackwardsStack.isNotEmpty;
  }
}

/// Reverses the order of a stack.
ImmutableStack _reverseStack(ImmutableStack stack) {
  var r = new ImmutableStack.empty();
  for (ImmutableStack f = stack; f.isNotEmpty; f = f.pop()) {
    r = r.push(f.peek());
  }

  return r;
}

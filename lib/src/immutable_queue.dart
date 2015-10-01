part of immutable;

abstract class ImmutableQueue<E> implements Iterable<E> {
  /// Returns an empty collection.
  static final ImmutableQueue empty = _ImmutableQueue.empty;

  ///  Creates a new immutable collection prefilled with the specified [items].
  factory ImmutableQueue.from(Iterable<E> items) {
    if (items == null) {
      throw new ArgumentError.notNull('items');
    }

    var queue = _ImmutableQueue.empty;
    for (final item in items) {
      queue = queue.enqueue(item);
    }

    return queue;
  }

  /// Gets an empty queue.
  ImmutableQueue<E> clear();

  /// Gets the element at the front of the queue.
  ///
  /// [StateError] is thrown when the queue is empty.
  E peek();

  /// Adds an element to the back of the queue and returns a new queue.
  ImmutableQueue<E> enqueue(E value);

  /// Returns a queue that is missing the front element.
  ///
  /// [StateError] is thrown when the queue is empty.
  ImmutableQueue<E> dequeue();
}

class _ImmutableQueue<E> extends IterableBase<E> implements ImmutableQueue<E> {
  static final _ImmutableQueue empty =
      new _ImmutableQueue(_ImmutableStack.empty, _ImmutableStack.empty);

  /// The end of the queue that enqueued elements are pushed onto.
  final _ImmutableStack<E> _backwards;

  /// The end of the queue from which elements are dequeued.
  final _ImmutableStack<E> _forwards;

  /// Backing field for the [backwardsReversed] property.
  _ImmutableStack<E> _backwardsReversed;

  _ImmutableQueue(_ImmutableStack<E> forwards, _ImmutableStack<E> backwards)
      : _forwards = forwards,
        _backwards = backwards,
        _backwardsReversed = null {
    if (forwards == null) {
      throw new ArgumentError.notNull('forwards');
    }
    if (backwards == null) {
      throw new ArgumentError.notNull('backwards');
    }
  }

  /// Gets the empty queue.
  ImmutableQueue<E> clear() => empty;

  @override
  bool get isEmpty => _forwards.isEmpty && _backwards.isEmpty;

  _ImmutableStack<E> get backwardsReversed {
    if (_backwardsReversed == null) {
      _backwardsReversed = _backwards._reverse();
    }

    return _backwardsReversed;
  }

  @override
  E peek() {
    if (isEmpty) {
      throw new StateError('queue empty');
    }

    return _forwards.peek();
  }

  @override
  ImmutableQueue<E> enqueue(E value) {
    if (isEmpty) {
      return new _ImmutableQueue<E>(
          _ImmutableStack.empty.push(value), _ImmutableStack.empty);
    } else {
      return new _ImmutableQueue<E>(_forwards, _backwards.push(value));
    }
  }

  @override
  ImmutableQueue<E> dequeue() {
    if (isEmpty) {
      throw new StateError('queue empty');
    }

    _ImmutableStack<E> f = _forwards.pop();
    if (f.isNotEmpty) {
      return new _ImmutableQueue<E>(f, _backwards);
    } else if (_backwards.isEmpty) {
      return _ImmutableQueue.empty;
    } else {
      return new _ImmutableQueue<E>(backwardsReversed, _ImmutableStack.empty);
    }
  }

  Iterator<E> get iterator => new _ImmutableQueueIterator(this);
}

class _ImmutableQueueIterator<E> implements Iterator<E> {
  /// The original queue being enumerated.
  final _ImmutableQueue<E> _originalQueue;

  /// The remaining forwards stack of the queue being enumerated.
  _ImmutableStack<E> _remainingForwardsStack;

  /// The remaining backwards stack of the queue being enumerated.
  /// Its order is reversed when the field is first initialized.
  _ImmutableStack<E> _remainingBackwardsStack;

  _ImmutableQueueIterator(this._originalQueue);

  @override
  E get current {
    if (_remainingForwardsStack == null) {
      return null;
    }

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

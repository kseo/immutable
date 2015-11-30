part of immutable;

/// Attempts to discover an [ImmutableList] instance beneath
/// some iterable sequence if one exists.
_AvlImmutableList _tryCastToImmutableList(Iterable sequence) {
  if (sequence is _AvlImmutableList) {
    return sequence;
  }

  if (sequence is _AvlImmutableListBuilder) {
    return sequence.toImmutable();
  }

  return null;
}

class _AvlImmutableList<E> extends IterableBase<E> implements ImmutableList<E> {
  /// An empty immutable list.
  static final _AvlImmutableList _empty = new _AvlImmutableList();

  /// The root node of the AVL tree that stores this set.
  final _AvlNode _root;

  _AvlImmutableList() : _root = _AvlNode.emptyNode;

  factory _AvlImmutableList.empty() => _empty;

  _AvlImmutableList.fromNode(this._root) {
    checkNotNull(_root);

    _root.freeze();
  }

  @override
  E get first {
    if (length == 0) throw IterableElementError.noElement();
    return this[0];
  }

  @override
  bool get isEmpty => _root.isEmpty;

  @override
  Iterator<E> get iterator => new _AvlImmutableListIterator(_root);

  @override
  E get last {
    if (length == 0) throw IterableElementError.noElement();
    return this[length - 1];
  }

  @override
  int get length => _root.length;

  @override
  Iterable<E> get reversed => new _ReversedIterable(_root);

  @override
  E get single {
    if (length == 0) throw IterableElementError.noElement();
    if (length > 1) throw IterableElementError.tooMany();
    return this[0];
  }

  @override
  E operator [](int index) => _root[index];

  @override
  ImmutableList<E> add(E value) {
    final result = _root.add(value);
    return _wrap(result);
  }

  @override
  ImmutableList<E> addAll(Iterable<E> iterable) {
    checkNotNull(iterable);
    if (this.isEmpty) return _fillFromEmpty(iterable);

    final result = _root.addAll(iterable);
    return _wrap(result);
  }

  @override
  ImmutableList<E> clear() => _empty;

  @override
  bool contains(Object element) => indexOf(element) >= 0;

  @override
  E elementAt(int index) => _root[index];

  @override
  ImmutableList<E> fillRange(int start, int end, [E fillValue]) {
    RangeError.checkValidRange(start, end, this.length);
    var result = this;
    for (int i = start; i < end; i++) {
      result = result.setItem(i, fillValue);
    }
    return result;
  }

  @override
  Iterable<E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    return new _SubListIterable<E>(_root, start, end);
  }

  @override
  int indexOf(E element, [int start = 0]) => _root.indexOf(element, start);

  @override
  ImmutableList<E> insert(int index, E element) {
    RangeError.checkValueInInterval(index, 0, length, "index");
    return _wrap(_root.insert(index, element));
  }

  @override
  ImmutableList<E> insertAll(int index, Iterable<E> iterable) {
    RangeError.checkValueInInterval(index, 0, length, "index");
    checkNotNull(iterable);

    final result = _root.insertAll(index, iterable);
    return _wrap(result);
  }

  @override
  int lastIndexOf(E element, [int start]) => _root.lastIndexOf(element, start);

  @override
  E lastWhere(bool test(E element), {E orElse()}) {
    for (E element in reversed) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  ImmutableList<E> remove(Object value) {
    int index = indexOf(value);
    return index < 0 ? this : removeAt(index);
  }

  @override
  ImmutableList<E> removeAt(int index) {
    RangeError.checkValidIndex(index, this);
    final result = _root.removeAt(index);
    return _wrap(result);
  }

  @override
  ImmutableList<E> removeLast() {
    final result = _root.removeAt(this.length - 1);
    return _wrap(result);
  }

  @override
  ImmutableList<E> removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);

    var result = _root;
    int remaining = end - start;
    while (remaining-- > 0) {
      result = result.removeAt(start);
    }

    return _wrap(result);
  }

  @override
  ImmutableList<E> removeWhere(bool test(E element)) {
    checkNotNull(test);

    return _wrap(_root.removeWhere(test));
  }

  @override
  ImmutableList<E> replaceRange(int start, int end, Iterable<E> newContents) {
    RangeError.checkValidRange(start, end, this.length);

    var result = this;
    var i = start;

    final iterator = newContents.iterator;
    while (iterator.moveNext()) {
      if (i < end) {
        result = result.setItem(i++, iterator.current);
      } else {
        result = result.insert(i++, iterator.current);
      }
    }
    if (i < end) {
      result = result.removeRange(i, end);
    }
    return result;
  }

  @override
  ImmutableList<E> retainWhere(bool test(E element)) {
    checkNotNull(test);

    return removeWhere((E element) => !test(element));
  }

  @override
  ImmutableList<E> setAll(int index, Iterable<E> iterable) {
    if (iterable is List) {
      return setRange(index, index + iterable.length, iterable);
    } else {
      var result = this;
      for (E element in iterable) {
        result = result.setItem(index++, element);
      }
      return result;
    }
  }

  @override
  ImmutableList<E> setItem(int index, E value) =>
      _wrap(_root.replaceAt(index, value));

  @override
  ImmutableList<E> setRange(int start, int end, Iterable<E> iterable,
      [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, this.length);
    int length = end - start;
    if (length == 0) return this;
    RangeError.checkNotNegative(skipCount, "skipCount");

    List otherList;
    int otherStart;
    if (iterable is List) {
      otherList = iterable;
      otherStart = skipCount;
    } else {
      otherList = iterable.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + length > otherList.length) {
      throw IterableElementError.tooFew();
    }
    var result = this;
    if (otherStart < start) {
      // Copy backwards to ensure correct copy if [from] is this.
      for (int i = length - 1; i >= 0; i--) {
        result = result.setItem(start + i, otherList[otherStart + i]);
      }
    } else {
      for (int i = 0; i < length; i++) {
        result = result.setItem(start + i, otherList[otherStart + i]);
      }
    }
    return result;
  }

  @override
  Iterable<E> skip(int count) =>
      new _SubListIterable<E>(_root, min(this.length, count), this.length);

  @override
  ImmutableList<E> sublist(int start, [int end]) {
    int listLength = this.length;
    if (end == null) end = listLength;
    RangeError.checkValidRange(start, end, listLength);

    return _wrap(_AvlNode.nodeTreeFromList(this.toList(), start, end - start));
  }

  @override
  Iterable<E> take(int count) =>
      new _SubListIterable<E>(_root, 0, min(count, this.length));

  @override
  ImmutableListBuilder toBuilder() => new _AvlImmutableListBuilder(this);

  /// Creates an immutable list with the contents from a sequence of elements.
  ImmutableList<E> _fillFromEmpty(Iterable<E> iterable) {
    assert(isEmpty);

    // If the items being added actually come from an ImmutableList<E>
    // then there is no value in reconstructing it.
    _AvlImmutableList<E> other = _tryCastToImmutableList(iterable);
    if (other != null) return other;

    // Rather than build up the immutable structure in the incremental way,
    // build it in such a way as to generate minimal garbage, by assembling
    // the immutable binary tree from leaf to root.  This requires
    // that we know the length of the item sequence in advance, and can
    // index into that sequence like a list, so the one possible piece of
    // garbage produced is a temporary array to store the list while
    // we build the tree.
    final list = iterable.toList();
    if (list.length == 0) return this;

    _AvlNode root = _AvlNode.nodeTreeFromList(list, 0, list.length);
    return new _AvlImmutableList<E>.fromNode(root);
  }

  ImmutableList<E> _wrap(_AvlNode root) {
    if (root != _root) {
      return root.isEmpty
          ? this.clear()
          : new _AvlImmutableList<E>.fromNode(root);
    } else {
      return this;
    }
  }

  static ImmutableList _wrapNode(_AvlNode root) {
    return root.isEmpty
        ? _AvlImmutableList._empty
        : new _AvlImmutableList.fromNode(root);
  }
}

class _AvlImmutableListBuilder<E> extends ListBase<E>
    implements ImmutableListBuilder<E> {
  /// The binary tree used to store the contents of the list.
  /// Contents are typically not entirely frozen.
  _AvlNode _rootUnsafe = _AvlNode.emptyNode;

  /// Caches an immutable instance that represents the current state of
  /// the collection.
  ///
  /// Null if no immutable view has been created for the current version.
  ImmutableList<E> _immutable;

  int _version = 0;

  _AvlImmutableListBuilder(_AvlImmutableList<E> list) {
    checkNotNull(list);
    _root = list._root;
    _immutable = list;
  }

  @override
  bool get isEmpty => _root.isEmpty;

  @override
  Iterator<E> get iterator => _root._iterator(this);

  @override
  int get length => _root.length;

  @override
  void set length(int newLength) => throw new UnimplementedError();

  @override
  Iterable<E> get reversed => new _ReversedIterable(_root);

  /// A number that increments every time the builder changes its contents.
  int get version => _version;

  _AvlNode get _root => _rootUnsafe;

  void set _root(_AvlNode newRoot) {
    _version++;

    if (_rootUnsafe != newRoot) {
      _rootUnsafe = newRoot;

      // Clear any cached value for the immutable view since it is now
      // invalidated.
      _immutable = null;
    }
  }

  @override
  E operator [](int index) => _root[index];

  @override
  void operator []=(int index, E value) {
    _root = _root.replaceAt(index, value);
  }

  @override
  void add(E element) {
    _root = _root.add(element);
  }

  @override
  void addAll(Iterable<E> iterable) {
    checkNotNull(iterable);
    _root = _root.addAll(iterable);
  }

  @override
  void clear() {
    _root = _AvlNode.emptyNode;
  }

  @override
  bool contains(Object element) => _root.indexOf(element) >= 0;

  @override
  Iterable<E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    return new _SubListIterable<E>(_root, start, end);
  }

  @override
  int indexOf(Object element, [int startIndex = 0]) =>
      _root.indexOf(element, startIndex);

  @override
  void insert(int index, E element) {
    RangeError.checkValueInInterval(index, 0, length, "index");
    _root = _root.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    RangeError.checkValueInInterval(index, 0, length, "index");
    checkNotNull(iterable);

    _root = _root.insertAll(index, iterable);
  }

  @override
  int lastIndexOf(Object element, [int startIndex]) =>
      _root.lastIndexOf(element, startIndex);

  @override
  bool remove(Object element) {
    final index = indexOf(element);
    if (index < 0) return false;

    _root = _root.removeAt(index);
    return true;
  }

  @override
  E removeAt(int index) {
    // FIXME: Can we do this in one step?
    final element = _root[index];
    _root = _root.removeAt(index);
    return element;
  }

  @override
  E removeLast() {
    // FIXME: Can we do this in one step?
    final element = _root[this.length - 1];
    _root = _root.removeAt(this.length - 1);
    return element;
  }

  @override
  void removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);

    var result = _root;
    int remaining = end - start;
    while (remaining-- > 0) {
      result = result.removeAt(start);
    }

    _root = result;
  }

  @override
  void removeWhere(bool test(E element)) {
    checkNotNull(test);

    _root = _root.removeWhere(test);
  }

  @override
  void retainWhere(bool test(E element)) {
    checkNotNull(test);

    removeWhere((E element) => !test(element));
  }

  @override
  Iterable<E> skip(int count) =>
      new _SubListIterable<E>(_root, min(this.length, count), this.length);

  @override
  Iterable<E> take(int count) =>
      new _SubListIterable<E>(_root, 0, min(count, this.length));

  @override
  ImmutableList<E> toImmutable() {
    if (_immutable == null) {
      _immutable = _AvlImmutableList._wrapNode(_root);
    }

    return _immutable;
  }
}

class _AvlImmutableListIterator<E> implements Iterator<E> {
  /// The builder being iterated, if applicable.
  final _AvlImmutableListBuilder _builder;

  /// The starting index of the collection at which to begin iteration.
  final int _startIndex;

  /// The number of elements to include in the iteration.
  final int _count;

  /// The number of elements left in the iteration.
  int _remainingCount;

  /// A value indicating whether this iterator walks in reverse order.
  bool _reversed;

  /// The set being iterated.
  _AvlNode _root;

  /// The stack to use for iterating the binary tree.
  Stack<_AvlNode> _stack;

  /// The node currently selected.
  _AvlNode _current;

  /// The version of the builder (when applicable) that is being iterated.
  int _iteratingBuilderVersion;

  _AvlImmutableListIterator(_AvlNode root,
      {_AvlImmutableListBuilder builder,
      int startIndex: -1,
      int count: -1,
      bool reversed: false})
      : _root = root,
        _builder = builder,
        _startIndex =
            startIndex >= 0 ? startIndex : (reversed ? root.length - 1 : 0),
        _count = count == -1 ? root.length : count {
    checkNotNull(_root);
    if (startIndex < -1) {
      throw new ArgumentError('startIndex must be greater than or equal to -1');
    }
    if (count < -1) {
      throw new ArgumentError('count must be greater than or equal to -1');
    }
    assert(reversed ||
        count == -1 ||
        (startIndex == -1 ? 0 : startIndex) + count <= root.length);
    assert(!reversed ||
        count == -1 ||
        (startIndex == -1 ? root.length - 1 : startIndex) - count + 1 >= 0);

    _current = null;
    _remainingCount = _count;
    _reversed = reversed;
    _iteratingBuilderVersion = builder != null ? builder.version : -1;
    _stack = new Stack<_AvlNode>();
    _resetStack();
  }

  @override
  E get current => _current?.value;

  @override
  bool moveNext() {
    _throwIfChanged();

    if (_stack != null) {
      if (_remainingCount > 0 && _stack.length > 0) {
        _AvlNode n = _stack.pop();
        _current = n;
        _pushNext(_nextBranch(n));
        _remainingCount--;
        return true;
      }
    }

    _current = null;
    return false;
  }

  /// Obtains the right branch of the given node (or the left, if walking
  /// in reverse).
  _AvlNode _nextBranch(_AvlNode node) => _reversed ? node.left : node.right;

  /// Obtains the left branch of the given node (or the right, if walking
  /// in reverse).
  _AvlNode _previousBranch(_AvlNode node) => _reversed ? node.right : node.left;

  void _pushNext(_AvlNode node) {
    checkNotNull(node);

    while (node.isNotEmpty) {
      _stack.push(node);
      node = _previousBranch(node);
    }
  }

  void _resetStack() {
    _stack.clear();

    var node = _root;
    var skipNodes = _reversed ? _root.length - _startIndex - 1 : _startIndex;
    while (node.isNotEmpty && skipNodes != _previousBranch(node).length) {
      if (skipNodes < _previousBranch(node).length) {
        _stack.push(node);
        node = _previousBranch(node);
      } else {
        skipNodes -= _previousBranch(node).length + 1;
        node = _nextBranch(node);
      }
    }

    if (node.isNotEmpty) _stack.push(node);
  }

  /// Throws an exception if the underlying builder's contents have been
  /// changed since enumeration started.
  ///
  /// [ConcurrentModificationError] is thrown if the collection has changed.
  void _throwIfChanged() {
    if (_builder != null && _builder.version != _iteratingBuilderVersion) {
      throw new ConcurrentModificationError(this);
    }
  }
}

/// A node in the AVL tree storing this set.
class _AvlNode<E> extends IterableBase<E>
    implements BinaryTree<E>, Iterable<E> {
  /// The default empty node.
  static _AvlNode emptyNode = new _AvlNode();

  /// The key associated with this node.
  E _key;

  /// A value indicating whether this node has been frozen (made immutable).
  ///
  /// Nodes must be frozen before ever being observed by a wrapping collection
  /// type to protect collections from further mutations.
  bool _frozen;

  /// The depth of the tree beneath this node.
  int _height; // AVL tree max height <= ~1.44 * log2(maxNodes + 2)

  /// The number of elements contained by this subtree starting at this node.
  int _length;

  /// The left tree.
  _AvlNode _left;

  /// The right tree.
  _AvlNode _right;

  _AvlNode()
      : _height = 0,
        _length = 0,
        _frozen = true; // the empty node is *always* frozen.

  _AvlNode.from(this._key, this._left, this._right, {bool frozen: false})
      : _frozen = frozen {
    checkNotNull(_left);
    checkNotNull(_right);

    _height = 1 + max(_left._height, _right._height);
    _length = 1 + _left._length + _right._length;
  }

  @override
  int get height => _height;

  @override
  bool get isEmpty => _left == null;

  @override
  Iterator<E> get iterator => new _AvlImmutableListIterator(this);

  @override
  _AvlNode get left => _left;

  @override
  int get length => _length;

  @override
  _AvlNode get right => _right;

  @override
  E get value => _key;

  /// Gets the element of the set at the given index.
  E operator [](int index) {
    RangeError.checkValidIndex(index, this);

    if (index < _left._length) return _left[index];
    if (index > _left._length) return _right[index - _left._length - 1];

    return _key;
  }

  /// Adds the specified key to the tree.
  _AvlNode add(E key) => insert(_length, key);

  /// Adds the specified keys to the tree.
  _AvlNode addAll(Iterable<E> keys) => insertAll(_length, keys);

  /// Freezes this node and all descendant nodes so that any mutations require
  /// a new instance of the nodes.
  void freeze() {
    // If this node is frozen, all its descendants must already be frozen.
    if (!_frozen) {
      _left.freeze();
      _right.freeze();
      _frozen = true;
    }
  }

  int indexOf(E element, [int startIndex = 0]) =>
      _indexOf(element, startIndex: startIndex);

  int _indexOf(E element, {int startIndex, EqualityComparator comparator}) {
    if (startIndex >= _length) return -1;
    if (startIndex < 0) startIndex = 0;
    comparator ??= EqualityComparator.defaultComparator;

    final iterator = new _AvlImmutableListIterator(this, startIndex: startIndex);
    var index = startIndex;
    while (iterator.moveNext()) {
      if (comparator.equals(element, iterator.current)) {
        return index;
      }

      index++;
    }

    return -1;
  }

  /// Adds a value at a given index to this node.
  _AvlNode insert(int index, E key) {
    if (index < 0 || index > _length) throw new RangeError('index');

    if (isEmpty) {
      return new _AvlNode.from(key, this, this);
    } else {
      _AvlNode result;
      if (index <= _left._length) {
        final newLeft = _left.insert(index, key);
        result = this._mutate(left: newLeft);
      } else {
        final newRight = _right.insert(index - _left._length - 1, key);
        result = this._mutate(right: newRight);
      }

      return _makeBalanced(result);
    }
  }

  /// Adds a collection of values at a given index to this node.
  _AvlNode insertAll(int index, Iterable<E> keys) {
    RangeError.checkValueInInterval(index, 0, _length, "index");
    checkNotNull(keys);

    if (isEmpty) {
      _AvlImmutableList<E> other = _tryCastToImmutableList(keys);
      if (other != null) return other._root;

      final list = keys.toList();
      return _AvlNode.nodeTreeFromList(list, 0, list.length);
    } else {
      _AvlNode result;
      if (index <= _left._length) {
        final newLeft = _left.insertAll(index, keys);
        result = _mutate(left: newLeft);
      } else {
        final newRight = _right.insertAll(index - _left._length - 1, keys);
        result = _mutate(right: newRight);
      }

      return _balanceNode(result);
    }
  }

  int lastIndexOf(E element, [int startIndex]) {
    if (startIndex == null) {
      startIndex = _length - 1;
    } else {
      if (startIndex < 0) return -1;
      if (startIndex >= _length) startIndex = _length - 1;
    }

    final iterator = new _AvlImmutableListIterator(this,
        startIndex: startIndex, reversed: true);
    var index = startIndex;
    while (iterator.moveNext()) {
      if (element == iterator.current) return index;
      index--;
    }

    return -1;
  }

  /// Removes a value at a given index to this node.
  _AvlNode removeAt(int index) {
    RangeError.checkValidIndex(index, this);

    var result = this;
    if (index == _left.length) {
      // We have a match. If this is a leaf, just remove it
      // by returning Empty.  If we have only one child,
      // replace the node with the child.
      if (_right.isEmpty && _left.isEmpty) {
        result = emptyNode;
      } else if (_right.isEmpty && !_left.isEmpty) {
        result = _left;
      } else if (!_right.isEmpty && _left.isEmpty) {
        result = _right;
      } else {
        // We have two children. Remove the next-highest node and replace
        // this node with it.
        var successor = _right;
        while (!successor._left.isEmpty) {
          successor = successor._left;
        }

        final newRight = _right.removeAt(0);
        result = successor._mutate(left: _left, right: newRight);
      }
    } else if (index < _left.length) {
      final newLeft = _left.removeAt(index);
      result = this._mutate(left: newLeft);
    } else {
      final newRight = _right.removeAt(index - _left._length - 1);
      result = this._mutate(right: newRight);
    }

    return result.isEmpty ? result : _makeBalanced(result);
  }

  _AvlNode removeWhere(bool test(E element)) {
    checkNotNull(test);

    var result = this;
    int index = 0;
    for (final item in this) {
      if (test(item)) {
        result = result.removeAt(index);
      } else {
        index++;
      }
    }

    return result;
  }

  _AvlNode replaceAt(int index, E value) {
    RangeError.checkValidIndex(index, this);

    var result = this;
    if (index == _left._length) {
      // We have a match.
      result = this._mutateValue(value);
    } else if (index < _left._length) {
      final newLeft = _left.replaceAt(index, value);
      result = this._mutate(left: newLeft);
    } else {
      final newRight = _right.replaceAt(index - _left._length - 1, value);
      result = this._mutate(right: newRight);
    }

    return result;
  }

  Iterator<E> _iterator(ImmutableListBuilder builder) =>
      new _AvlImmutableListIterator(this, builder: builder);

  /// Creates a node mutation, either by mutating this node (if not yet frozen)
  /// or by creating a clone of this node with the described changes.
  _AvlNode _mutate({_AvlNode left: null, _AvlNode right: null}) {
    if (_frozen) {
      return new _AvlNode.from(_key, left ?? _left, right ?? _right);
    } else {
      if (left != null) _left = left;
      if (right != null) _right = right;

      _height = 1 + max(_left._height, _right._height);
      _length = 1 + _left._length + _right._length;
      return this;
    }
  }

  _AvlNode _mutateValue(E value) {
    if (_frozen) {
      return new _AvlNode.from(value, _left, _right);
    } else {
      _key = value;
      return this;
    }
  }

  /// Creates a node tree that contains the contents of a list.
  static _AvlNode nodeTreeFromList(List items, int start, int length) {
    checkNotNull(items);
    RangeError.checkNotNegative(start, 'start');
    RangeError.checkNotNegative(length, 'length');
    if (length == 0) return emptyNode;

    int rightLength = (length - 1) ~/ 2;
    int leftLength = (length - 1) - rightLength;
    final left = nodeTreeFromList(items, start, leftLength);
    final right = nodeTreeFromList(items, start + leftLength + 1, rightLength);
    return new _AvlNode.from(items[start + leftLength], left, right,
        frozen: true);
  }

  static int _balance(_AvlNode tree) {
    checkNotNull(tree);

    return tree._right._height - tree._left.height;
  }

  /// Balance the specified node. Allows for a large imbalance between
  /// left and right nodes, but assumes left and right nodes are
  /// individually balanced.
  static _AvlNode _balanceNode(_AvlNode node) {
    while (_isRightHeavy(node) || _isLeftHeavy(node)) {
      if (_isRightHeavy(node)) {
        node =
            _balance(node._right) < 0 ? _doubleLeft(node) : _rotateLeft(node);
        node._mutate(left: _balanceNode(node._left));
      } else {
        node =
            _balance(node._left) > 0 ? _doubleRight(node) : _rotateRight(node);
        node._mutate(right: _balanceNode(node._right));
      }
    }
    return node;
  }

  /// AVL rotate double-left operation.
  static _AvlNode _doubleLeft(_AvlNode tree) {
    checkNotNull(tree);
    if (tree._right.isEmpty) return tree;

    final rotatedRightChild = tree._mutate(right: _rotateRight(tree._right));
    return _rotateLeft(rotatedRightChild);
  }

  /// AVL rotate double-right operation.
  static _AvlNode _doubleRight(_AvlNode tree) {
    checkNotNull(tree);
    if (tree._left.isEmpty) return tree;

    final rotatedLeftChild = tree._mutate(left: _rotateLeft(tree._left));
    return _rotateRight(rotatedLeftChild);
  }

  static bool _isLeftHeavy(_AvlNode tree) {
    checkNotNull(tree);

    return _balance(tree) <= -2;
  }

  static bool _isRightHeavy(_AvlNode tree) {
    checkNotNull(tree);

    return _balance(tree) >= 2;
  }

  /// Balances the specified tree.
  static _AvlNode _makeBalanced(_AvlNode tree) {
    checkNotNull(tree);

    if (_isRightHeavy(tree)) {
      return _balance(tree._right) < 0 ? _doubleLeft(tree) : _rotateLeft(tree);
    }

    if (_isLeftHeavy(tree)) {
      return _balance(tree._left) > 0 ? _doubleRight(tree) : _rotateRight(tree);
    }

    return tree;
  }

  /// AVL rotate left operation.
  static _AvlNode _rotateLeft(_AvlNode tree) {
    checkNotNull(tree);
    if (tree._right.isEmpty) return tree;

    final right = tree._right;
    return right._mutate(left: tree._mutate(right: right._left));
  }

  /// AVL rotate right operation.
  static _AvlNode _rotateRight(_AvlNode tree) {
    checkNotNull(tree);
    if (tree._left.isEmpty) return tree;

    final left = tree._left;
    return left._mutate(right: tree._mutate(left: left._right));
  }
}

class _ReversedIterable<E> extends IterableBase<E> {
  final _AvlNode _root;

  _ReversedIterable(this._root);

  @override
  Iterator<E> get iterator =>
      new _AvlImmutableListIterator<E>(_root, reversed: true);
}

class _SubListIterable<E> extends IterableBase<E> {
  final _AvlNode _root;
  final int _start;
  final int _end;

  _SubListIterable(this._root, this._start, this._end) {
    RangeError.checkNotNegative(_start, 'start');
    RangeError.checkNotNegative(_end, 'end');
    if (_start > _end) {
      throw new RangeError.range(_start, 0, _end, 'start');
    }
  }

  @override
  Iterator<E> get iterator => new _AvlImmutableListIterator<E>(_root,
      startIndex: _start, count: _end - _start);
}

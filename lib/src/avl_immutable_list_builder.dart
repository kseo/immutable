part of immutable;

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


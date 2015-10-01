part of immutable;

/// Attempts to discover an [ImmutableList] instance beneath
/// some iterable sequence if one exists.
_ImmutableList _tryCastToImmutableList(Iterable sequence) {
  if (sequence is _ImmutableList) {
    return sequence;
  }

  if (sequence is _ImmutableListBuilder) {
    return sequence.toImmutable();
  }

  return null;
}

/// A list of elements that can only be modified by creating a new
/// instance of the list.
///
/// Mutations on this list generate new lists. Incremental changes to
/// a list share as much memory as possible with the prior versions of
/// a list, while allowing garbage collection to clean up any unique list
/// data that is no longer being referenced.
abstract class ImmutableList<E> implements Iterable<E> {
  /// An empty [ImmutableList].
  factory ImmutableList.empty() => new _ImmutableList<E>.empty();

  /// Creates a list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  factory ImmutableList.from(Iterable<E> elements) =>
      new _ImmutableList<E>.empty().addAll(elements);

  /// Returns an [Iterable] of the objects in this list in reverse order.
  Iterable<E> get reversed;

  /// Returns the object at the given [index] in the list
  /// or throws a [RangeError] if [index] is out of bounds.
  E operator [](int index);

  /// Returns a new list with [value] added to the end of this list.
  ImmutableList<E> add(E value);

  /// Returns a new list with all objects of [iterable] added to the end of
  /// this list.
  ImmutableList<E> addAll(Iterable<E> iterable);

  /// Gets an empty list.
  ImmutableList<E> clear();

  /// Sets the objects in the range [start] inclusive to [end] exclusive to
  /// the given [fillValue].
  ///
  /// An error occurs if [start]..[end] is not a valid range for `this`.
  ImmutableList<E> fillRange(int start, int end, [E fillValue]);

  /// Returns an [Iterable] that iterates over the objects in the range
  /// [start] inclusive to [end] exclusive.
  ///
  /// An error occurs if [end] is before [start].
  ///
  /// An error occurs if the [start] and [end] are not valid ranges at the time
  /// of the call to this method.
  ///
  ///     List<String> colors = ['red', 'green', 'blue', 'orange', 'pink'];
  ///     Iterable<String> range = colors.getRange(1, 4);
  ///     range.join(', ');  // 'green, blue, orange'
  ///     colors.length = 3;
  ///     range.join(', ');  // 'green, blue'
  Iterable<E> getRange(int start, int end);

  /// Returns the first index of [element] in this list.
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object [:o:] is encountered so that [:o == element:],
  /// the index of [:o:] is returned.
  ///
  ///    List<String> notes = ['do', 're', 'mi', 're'];
  ///    notes.indexOf('re');    // 1
  ///    notes.indexOf('re', 2); // 3
  ///
  /// Returns -1 if [element] is not found.
  ///
  ///     notes.indexOf('fa');    // -1
  int indexOf(E element, [int start = 0]);

  /// Inserts the object at position [index] in this list.
  ///
  /// This increases the length of the list by one and shifts all objects
  /// at or after the index towards the end of the list.
  ///
  /// An error occurs if the [index] is less than 0 or greater than length.
  ImmutableList<E> insert(int index, E element);

  /// Inserts all objects of [iterable] at position [index] in this list.
  ///
  /// This increases the length of the list by the length of iterable and
  /// shifts all later objects towards the end of the list.
  ///
  /// An error occurs if the [index] is less than 0 or greater than length.
  ImmutableList<E> insertAll(int index, Iterable<E> iterable);

  /// Returns the last index of [element] in this list.
  ///
  /// Searches the list backwards from index [start] to 0.
  ///
  /// The first time an object [:o:] is encountered so that [:o == element:],
  /// the index of [:o:] is returned.
  ///
  ///     List<String> notes = ['do', 're', 'mi', 're'];
  ///     notes.lastIndexOf('re', 2); // 1
  ///
  /// If [start] is not provided, this method searches from the end of the
  /// list./Returns
  ///
  ///     notes.lastIndexOf('re');  // 3
  ///
  /// Returns -1 if [element] is not found.
  ///
  ///     notes.lastIndexOf('fa');  // -1
  int lastIndexOf(E element, [int start]);

  /// Removes the first occurence of [value] from this list and returns a
  /// new list with the element removed, or this list if the element is not
  /// in this list.
  ///
  ///     List<String> parts = ['head', 'shoulders', 'knees', 'toes'];
  ///     parts = parts.remove('head');
  ///     parts.join(', ');     // 'shoulders, knees, toes'
  ///
  /// The method has no effect if value was not in the list.
  ///
  ///     // Note: 'head' has already been removed.
  ///     parts = parts.remove('head');
  ///     parts.join(', ');     // 'shoulders, knees, toes'
  ImmutableList<E> remove(Object value);

  /// Removes the object at position index from this list.
  ///
  /// This method reduces the length of `this` by one and moves all later
  /// objects down by one position.
  ///
  /// The [index] must be in the range `0 ≤ index < length`.
  ImmutableList<E> removeAt(int index);

  /// Removes the last object in this list.
  ImmutableList<E> removeLast();

  /// Removes the objects in the range [start] inclusive to [end] exclusive.
  ///
  /// The [start] and [end] indices must be in the range
  /// `0 ≤ index ≤ length`, and `start ≤ end`.
  ImmutableList<E> removeRange(int start, int end);

  /// Removes all objects from this list that satisfy [test].
  ///
  /// An object [:o:] satisfies [test] if [:test(o):] is true.
  ///
  ///     List<String> numbers = ['one', 'two', 'three', 'four'];
  ///     numbers = numbers.removeWhere((item) => item.length == 3);
  ///     numbers.join(', '); // 'three, four'
  ImmutableList<E> removeWhere(bool test(E element));

  /// Removes the objects in the range [start] inclusive to [end] exclusive
  /// and inserts the contents of [replacement] in its place.
  ///
  ///     List<int> list = [1, 2, 3, 4, 5];
  ///     list = list.replaceRange(1, 4, [6, 7]);
  ///     list.join(', '); // '1, 6, 7, 5'
  ///
  /// An error occurs if [start]..[end] is not a valid range for `this`.
  ImmutableList<E> replaceRange(int start, int end, Iterable<E> replacement);

  /// Removes all objects from this list that fail to satisfy [test].
  ///
  /// An object [:o:] satisfies [test] if [:test(o):] is true.
  ///
  ///     List<String> numbers = ['one', 'two', 'three', 'four'];
  ///     numbers = numbers.retainWhere((item) => item.length == 3);
  ///     numbers.join(', '); // 'one, two'
  ImmutableList<E> retainWhere(bool test(E element));

  /// Overwrites objects of `this` with the objects of [iterable], starting
  /// at position [index] in this list.
  ///
  ///     List<String> list = ['a', 'b', 'c'];
  ///     list = list.setAll(1, ['bee', 'sea']);
  ///     list.join(', '); // 'a, bee, sea'
  ///
  /// This operation does not increase the length of `this`.
  ///
  /// The [index] must be non-negative and no greater than [length].
  ///
  /// The [iterable] must not have more elements than what can fit from [index]
  /// to [length].
  ImmutableList<E> setAll(int index, Iterable<E> iterable);

  /// Sets the value at the given [index] in the list to [value] or
  /// throws a [RangeError] if [index] is out of bounds.
  ImmutableList<E> setItem(int index, E value);

  /// Copies the objects of [iterable], skipping [skipCount] objects first,
  /// into the range [start], inclusive, to [end], exclusive, of the list.
  ///
  ///     List<int> list1 = [1, 2, 3, 4];
  ///     List<int> list2 = [5, 6, 7, 8, 9];
  ///     // Copies the 4th and 5th items in list2 as the 2nd and 3rd items
  ///     // of list1.
  ///     list1 = list1.setRange(1, 3, list2, 3);
  ///     list1.join(', '); // '1, 8, 9, 4'
  ///
  /// The [start] and [end] indices must satisfy `0 ≤ start ≤ end ≤ length`.
  /// If [start] equals [end], this method has no effect.
  ///
  /// The [iterable] must have enough objects to fill the range from `start`
  /// to `end` after skipping [skipCount] objects.
  ///
  /// If `iterable` is this list, the operation will copy the elements originally
  /// in the range from `skipCount` to `skipCount + (end - start)` to the
  /// range `start` to `end`, even if the two ranges overlap.
  ///
  /// If `iterable` depends on this list in some other way, no guarantees are
  /// made.
  ImmutableList<E> setRange(int start, int end, Iterable<E> iterable,
      [int skipCount = 0]);

  /// Returns a new list containing the objects from [start] inclusive to [end]
  /// exclusive.
  ///
  ///     List<String> colors = ['red', 'green', 'blue', 'orange', 'pink'];
  ///     colors.sublist(1, 3); // ['green', 'blue']
  ///
  /// If [end] is omitted, the [length] of `this` is used.
  ///
  ///     colors.sublist(1);  // ['green', 'blue', 'orange', 'pink']
  ///
  /// An error occurs if [start] is outside the range `0` .. `length` or if
  /// [end] is outside the range `start` .. `length`.
  ImmutableList<E> sublist(int start, [int end]);

  /// Creates a collection with the same contents as this collection that
  /// can be efficiently mutated across multiple operations using standard
  /// mutable interfaces.
  ///
  /// This is an O(1) operation and results in only a single (small) memory
  /// allocation.
  ImmutableListBuilder toBuilder();
}

/// A list that mutates with little or no memory allocations,
/// can produce and/or build on immutable list instances very efficiently.
abstract class ImmutableListBuilder<E> implements List<E> {
  /// Creates a new immutable list builder.
  factory ImmutableListBuilder.empty() => new _ImmutableList<E>.empty().toBuilder();

  /// Creates a [ImmutableList] based on the contents of this instance.
  ImmutableList<E> toImmutable();
}

class _ImmutableList<E> extends IterableBase<E> implements ImmutableList<E> {
  /// An empty immutable list.
  static final _ImmutableList _empty = new _ImmutableList();

  /// The root node of the AVL tree that stores this set.
  final _Node _root;

  _ImmutableList() : _root = _Node.emptyNode;

  factory _ImmutableList.empty() => _empty;

  _ImmutableList.fromNode(this._root) {
    if (_root == null) throw new ArgumentError.notNull('root');

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
  Iterator<E> get iterator => new _ImmutableListIterator(_root);

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
    if (iterable == null) throw new ArgumentError.notNull('iterable');
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
    if (iterable == null) throw new ArgumentError.notNull('iterable');

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
    if (test == null) throw new ArgumentError.notNull('test');

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
    if (test == null) throw new ArgumentError.notNull('test');

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

    return _wrap(_Node.nodeTreeFromList(this.toList(), start, end - start));
  }

  @override
  Iterable<E> take(int count) =>
      new _SubListIterable<E>(_root, 0, min(count, this.length));

  @override
  ImmutableListBuilder toBuilder() => new _ImmutableListBuilder(this);

  /// Creates an immutable list with the contents from a sequence of elements.
  ImmutableList<E> _fillFromEmpty(Iterable<E> iterable) {
    assert(isEmpty);

    // If the items being added actually come from an ImmutableList<E>
    // then there is no value in reconstructing it.
    _ImmutableList<E> other = _tryCastToImmutableList(iterable);
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

    _Node root = _Node.nodeTreeFromList(list, 0, list.length);
    return new _ImmutableList<E>.fromNode(root);
  }

  ImmutableList<E> _wrap(_Node root) {
    if (root != _root) {
      return root.isEmpty ? this.clear() : new _ImmutableList<E>.fromNode(root);
    } else {
      return this;
    }
  }

  static ImmutableList _wrapNode(_Node root) {
    return root.isEmpty ? _ImmutableList._empty : new _ImmutableList.fromNode(root);
  }
}

class _ImmutableListBuilder<E> extends ListBase<E>
    implements ImmutableListBuilder<E> {
  /// The binary tree used to store the contents of the list.
  /// Contents are typically not entirely frozen.
  _Node _rootUnsafe = _Node.emptyNode;

  /// Caches an immutable instance that represents the current state of
  /// the collection.
  ///
  /// Null if no immutable view has been created for the current version.
  ImmutableList<E> _immutable;

  int _version = 0;

  _ImmutableListBuilder(_ImmutableList<E> list) {
    if (list == null) throw new ArgumentError.notNull('list');
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

  _Node get _root => _rootUnsafe;

  void set _root(_Node newRoot) {
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
    if (iterable == null) throw new ArgumentError.notNull('iterable');
    _root = _root.addAll(iterable);
  }

  @override
  void clear() {
    _root = _Node.emptyNode;
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
    if (iterable == null) throw new ArgumentError.notNull('iterable');

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
    if (test == null) throw new ArgumentError.notNull('test');

    _root = _root.removeWhere(test);
  }

  @override
  void retainWhere(bool test(E element)) {
    if (test == null) throw new ArgumentError.notNull('test');

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
      _immutable = _ImmutableList._wrapNode(_root);
    }

    return _immutable;
  }
}

class _ImmutableListIterator<E> implements Iterator<E> {
  /// The builder being iterated, if applicable.
  final _ImmutableListBuilder _builder;

  /// The starting index of the collection at which to begin iteration.
  final int _startIndex;

  /// The number of elements to include in the iteration.
  final int _count;

  /// The number of elements left in the iteration.
  int _remainingCount;

  /// A value indicating whether this iterator walks in reverse order.
  bool _reversed;

  /// The set being iterated.
  _Node _root;

  /// The stack to use for iterating the binary tree.
  Stack<_Node> _stack;

  /// The node currently selected.
  _Node _current;

  /// The version of the builder (when applicable) that is being iterated.
  int _iteratingBuilderVersion;

  _ImmutableListIterator(_Node root,
      {_ImmutableListBuilder builder,
      int startIndex: -1,
      int count: -1,
      bool reversed: false})
      : _root = root,
        _builder = builder,
        _startIndex =
            startIndex >= 0 ? startIndex : (reversed ? root.length - 1 : 0),
        _count = count == -1 ? root.length : count {
    if (_root == null) throw new ArgumentError.notNull('root');
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
    _stack = new Stack<_Node>();
    _resetStack();
  }

  @override
  E get current => _current?.value;

  @override
  bool moveNext() {
    _throwIfChanged();

    if (_stack != null) {
      if (_remainingCount > 0 && _stack.length > 0) {
        _Node n = _stack.pop();
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
  _Node _nextBranch(_Node node) => _reversed ? node.left : node.right;

  /// Obtains the left branch of the given node (or the right, if walking
  /// in reverse).
  _Node _previousBranch(_Node node) => _reversed ? node.right : node.left;

  void _pushNext(_Node node) {
    if (node == null) throw new ArgumentError.notNull('node');

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
class _Node<E> extends IterableBase<E> implements BinaryTree<E>, Iterable<E> {
  /// The default empty node.
  static _Node emptyNode = new _Node();

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
  _Node _left;

  /// The right tree.
  _Node _right;

  _Node()
      : _height = 0,
        _length = 0,
        _frozen = true; // the empty node is *always* frozen.

  _Node.from(this._key, this._left, this._right, {bool frozen: false})
      : _frozen = frozen {
    if (_left == null) throw new ArgumentError.notNull('left');
    if (_right == null) throw new ArgumentError.notNull('right');

    _height = 1 + max(_left._height, _right._height);
    _length = 1 + _left._length + _right._length;
  }

  @override
  int get height => _height;

  @override
  bool get isEmpty => _left == null;

  @override
  Iterator<E> get iterator => new _ImmutableListIterator(this);

  @override
  _Node get left => _left;

  @override
  int get length => _length;

  @override
  _Node get right => _right;

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
  _Node add(E key) => insert(_length, key);

  /// Adds the specified keys to the tree.
  _Node addAll(Iterable<E> keys) => insertAll(_length, keys);

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

  int indexOf(E element, [int startIndex = 0]) {
    if (startIndex >= _length) return -1;
    if (startIndex < 0) startIndex = 0;

    final iterator = new _ImmutableListIterator(this, startIndex: startIndex);
    var index = startIndex;
    while (iterator.moveNext()) {
      if (element == iterator.current) {
        return index;
      }

      index++;
    }

    return -1;
  }

  /// Adds a value at a given index to this node.
  _Node insert(int index, E key) {
    if (index < 0 || index > _length) throw new RangeError('index');

    if (isEmpty) {
      return new _Node.from(key, this, this);
    } else {
      _Node result;
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
  _Node insertAll(int index, Iterable<E> keys) {
    RangeError.checkValueInInterval(index, 0, _length, "index");
    if (keys == null) throw new ArgumentError.notNull('keys');

    if (isEmpty) {
      _ImmutableList<E> other = _tryCastToImmutableList(keys);
      if (other != null) return other._root;

      final list = keys.toList();
      return _Node.nodeTreeFromList(list, 0, list.length);
    } else {
      _Node result;
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

    final iterator = new _ImmutableListIterator(this,
        startIndex: startIndex, reversed: true);
    var index = startIndex;
    while (iterator.moveNext()) {
      if (element == iterator.current) return index;
      index--;
    }

    return -1;
  }

  /// Removes a value at a given index to this node.
  _Node removeAt(int index) {
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

  _Node removeWhere(bool test(E element)) {
    if (test == null) throw new ArgumentError.notNull('test');

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

  _Node replaceAt(int index, E value) {
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
      new _ImmutableListIterator(this, builder: builder);

  /// Creates a node mutation, either by mutating this node (if not yet frozen)
  /// or by creating a clone of this node with the described changes.
  _Node _mutate({_Node left: null, _Node right: null}) {
    if (_frozen) {
      return new _Node.from(_key, left ?? _left, right ?? _right);
    } else {
      if (left != null) _left = left;
      if (right != null) _right = right;

      _height = 1 + max(_left._height, _right._height);
      _length = 1 + _left._length + _right._length;
      return this;
    }
  }

  _Node _mutateValue(E value) {
    if (_frozen) {
      return new _Node.from(value, _left, _right);
    } else {
      _key = value;
      return this;
    }
  }

  /// Creates a node tree that contains the contents of a list.
  static _Node nodeTreeFromList(List items, int start, int length) {
    if (items == null) throw new ArgumentError.notNull('items');
    RangeError.checkNotNegative(start, 'start');
    RangeError.checkNotNegative(length, 'length');
    if (length == 0) return emptyNode;

    int rightLength = (length - 1) ~/ 2;
    int leftLength = (length - 1) - rightLength;
    final left = nodeTreeFromList(items, start, leftLength);
    final right = nodeTreeFromList(items, start + leftLength + 1, rightLength);
    return new _Node.from(items[start + leftLength], left, right, frozen: true);
  }

  static int _balance(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');

    return tree._right._height - tree._left.height;
  }

  /// Balance the specified node. Allows for a large imbalance between
  /// left and right nodes, but assumes left and right nodes are
  /// individually balanced.
  static _Node _balanceNode(_Node node) {
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
  static _Node _doubleLeft(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');
    if (tree._right.isEmpty) return tree;

    final rotatedRightChild = tree._mutate(right: _rotateRight(tree._right));
    return _rotateLeft(rotatedRightChild);
  }

  /// AVL rotate double-right operation.
  static _Node _doubleRight(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');
    if (tree._left.isEmpty) return tree;

    final rotatedLeftChild = tree._mutate(left: _rotateLeft(tree._left));
    return _rotateRight(rotatedLeftChild);
  }

  static bool _isLeftHeavy(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');

    return _balance(tree) <= -2;
  }

  static bool _isRightHeavy(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');

    return _balance(tree) >= 2;
  }

  /// Balances the specified tree.
  static _Node _makeBalanced(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');

    if (_isRightHeavy(tree)) {
      return _balance(tree._right) < 0 ? _doubleLeft(tree) : _rotateLeft(tree);
    }

    if (_isLeftHeavy(tree)) {
      return _balance(tree._left) > 0 ? _doubleRight(tree) : _rotateRight(tree);
    }

    return tree;
  }

  /// AVL rotate left operation.
  static _Node _rotateLeft(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');
    if (tree._right.isEmpty) return tree;

    final right = tree._right;
    return right._mutate(left: tree._mutate(right: right._left));
  }

  /// AVL rotate right operation.
  static _Node _rotateRight(_Node tree) {
    if (tree == null) throw new ArgumentError.notNull('tree');
    if (tree._left.isEmpty) return tree;

    final left = tree._left;
    return left._mutate(right: tree._mutate(left: left._right));
  }
}

class _ReversedIterable<E> extends IterableBase<E> {
  final _Node _root;

  _ReversedIterable(this._root);

  @override
  Iterator<E> get iterator =>
      new _ImmutableListIterator<E>(_root, reversed: true);
}

class _SubListIterable<E> extends IterableBase<E> {
  final _Node _root;
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
  Iterator<E> get iterator => new _ImmutableListIterator<E>(_root,
      startIndex: _start, count: _end - _start);
}

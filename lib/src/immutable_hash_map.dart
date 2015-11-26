part of immutable;

/// An immutable unordered map implementation.
class ImmutableHashMap<K, V> implements ImmutableMap<K, V> {
  static final _Freeze _freezeBucketFunction = (KeyValuePair kv) =>
      kv.value.freeze();

  static final ImmutableHashMap _empty = new ImmutableHashMap.empty();

  int _length;

  final _Comparators _comparators;

  _SortedIntKeyNode<_HashBucket> _root;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  int get length => _length;

  _MutationInput get _origin => new _MutationInput.from(this);

  @override
  Iterable<K> get keys sync* {
    for (final bucket in _root) {
      for (final item in bucket.value) {
        yield item.key;
      }
    }
  }

  @override
  Iterable<V> get values sync* {
    for (final bucket in _root) {
      for (final item in bucket.value) {
        yield item.value;
      }
    }
  }

  Iterable<KeyValuePair<K, V>> get _pairs sync* {
    for (final bucket in _root) {
      for (final item in bucket.value) {
        yield item;
      }
    }
  }

  ImmutableHashMap.empty([_Comparators comparators])
      : _comparators = comparators ?? _Comparators.defaultComparator,
        _root = _SortedIntKeyNode.emptyNode,
        _length = 0;

  ImmutableHashMap.from(
      _SortedIntKeyNode<_HashBucket> root, _Comparators comparators, int length)
      : _comparators = comparators ?? _Comparators.defaultComparator,
        _root = checkNotNull(root),
        _length = length {
    _root.freeze(_freezeBucketFunction);
  }

  @override
  V operator [](K key) {
    checkNotNull(key);
    return _tryGetValue(key, _origin);
  }

  @override
  bool containsKey(Object key) => _containsKey(key, _origin);

  @override
  bool containsValue(Object value) {
    for (final v in values) {
      if (_comparators.valueComparator.equals(value, v)) {
        return true;
      }
    }
    return false;
  }

  @override
  ImmutableMap<K, V> add(K key, V value) {
    checkNotNull(key);

    final result = _add(key, value, _KeyCollisionBehavior.setValue, _origin);
    return result.finalize(this);
  }

  @override
  ImmutableMap<K, V> addAll(ImmutableMap<K, V> other) {
    checkNotNull(other);

    if (other is ImmutableHashMap) {
      final otherMap = other as ImmutableHashMap;
      final result =
          _addAll(otherMap._pairs, _KeyCollisionBehavior.setValue, _origin);
      return result.finalize(this);
    } else {
      throw new AssertionError();
    }
  }

  /// Removes [key] and its associated value, if present, from the map.
  ImmutableMap<K, V> remove(Object key) {
    checkNotNull(key);

    final result = _remove(key, _origin);
    return result.finalize(this);
  }

  @override
  ImmutableMapBuilder<K, V> toBuilder() => new _ImmutableHashMapBuilder(this);

  @override
  ImmutableMap<K, V> clear() =>
      isEmpty ? this : emptyWithComparators(_comparators);

  static bool _containsKey(key, _MutationInput origin) {
    final hashCode = origin.keyComparator.getHashCode(key);
    final bucket = origin.root.tryGetValue(hashCode);
    if (bucket != null) {
      final value = bucket.tryGetValue(key, origin.keyOnlyComparator);
      return value != null;
    }
    return false;
  }

  static dynamic _tryGetValue(equalKey, _MutationInput origin) {
    final hashCode = origin.keyComparator.getHashCode(equalKey);
    final bucket = origin.root.tryGetValue(hashCode);
    return bucket?.tryGetValue(equalKey, origin.keyOnlyComparator);
  }

  static _MutationResult _add(
      key, value, _KeyCollisionBehavior behavior, _MutationInput origin) {
    checkNotNull(key);

    final hashCode = origin.keyComparator.getHashCode(key);
    final bucket =
        origin.root.getValueOrDefault(hashCode, () => new _HashBucket.empty());
    final result = new Out<_OperationResult>();
    final newBucket = bucket.add(key, value, origin.keyOnlyComparator,
        origin.valueComparator, behavior, result);
    if (result.value == _OperationResult.noChangeRequired) {
      return new _MutationResult.from(origin);
    }

    final newRoot = _updateRoot(
        origin.root, hashCode, newBucket, origin.hashBucketComparator);
    return new _MutationResult(
        newRoot, result.value == _OperationResult.sizeChanged ? 1 : 0);
  }

  static _MutationResult _addAll(Iterable<KeyValuePair> items,
      _KeyCollisionBehavior behavior, _MutationInput origin) {
    checkNotNull(items);

    int lengthAdjustment = 0;
    var newRoot = origin.root;
    for (final pair in items) {
      final hashCode = origin.keyComparator.getHashCode(pair.key);
      final bucket =
          newRoot.getValueOrDefault(hashCode, () => new _HashBucket.empty());
      final result = new Out<_OperationResult>();
      final newBucket = bucket.add(pair.key, pair.value, origin.keyOnlyComparator,
          origin.valueComparator, behavior, result);
      newRoot = _updateRoot(
          newRoot, hashCode, newBucket, origin.hashBucketComparator);
      if (result.value == _OperationResult.sizeChanged) {
        lengthAdjustment++;
      }
    }
    return new _MutationResult(newRoot, lengthAdjustment);
  }

  static _MutationResult _remove(key, _MutationInput origin) {
    final hashCode = origin.keyComparator.getHashCode(key);
    final bucket = origin.root.tryGetValue(hashCode);
    if (bucket != null) {
      Out<_OperationResult> result = new Out<_OperationResult>();
      final newRoot = _updateRoot(
          origin.root,
          hashCode,
          bucket.remove(key, origin.keyOnlyComparator, result),
          origin.hashBucketComparator);
      return new _MutationResult(
          newRoot, result.value == _OperationResult.sizeChanged ? -1 : 0);
    }
    return new _MutationResult.from(origin);
  }

  static _SortedIntKeyNode<_HashBucket> _updateRoot(
      _SortedIntKeyNode<_HashBucket> root,
      int hashCode,
      _HashBucket newBucket,
      EqualityComparator<_HashBucket> hashBucketComparator) {
    Out<bool> mutated = new Out<bool>();
    if (newBucket.isEmpty) {
      return root.remove(hashCode, mutated);
    } else {
      Out<bool> replacedExistingValue = new Out<bool>();
      return root.setItem(hashCode, newBucket, hashBucketComparator,
          replacedExistingValue, mutated);
    }
  }

  static ImmutableHashMap wrap(_SortedIntKeyNode<_HashBucket> root,
      _Comparators comparators, int length) {
    checkNotNull(root);
    checkNotNull(comparators);
    RangeError.checkNotNegative(length);
    return new ImmutableHashMap.from(root, comparators, length);
  }

  ImmutableHashMap<K, V> _wrap(_SortedIntKeyNode<_HashBucket<K, V>> root,
      int adjustedLengthIfDifferentRoot) {
    if (root == null) {
      return clear();
    }

    if (_root != root) {
      return root.isEmpty
          ? clear()
          : new ImmutableHashMap.from(
              root, _comparators, adjustedLengthIfDifferentRoot);
    }

    return this;
  }

  static ImmutableHashMap emptyWithComparators(_Comparators comparators) {
    checkNotNull(comparators);

    return _empty._comparators == comparators
        ? _empty
        : new ImmutableHashMap.empty(comparators);
  }
}

/// How to respond when a key collision is discovered.
enum _KeyCollisionBehavior {
  /// Sets the value for the given key, even if that overwrites an existing
  /// value.
  setValue,

  /// Skips the mutating operation if a key conflict is detected.
  skip,

  /// Throw an exception if the key already exists with a different key.
  throwIfValueDifferent,

  /// Throw an exception if the key already exists regardless of its value.
  throwAlways
}

/// The result of a mutation operation.
enum _OperationResult {
  /// The change was applied and did not require a change to the number of
  /// elements in the collection.
  appliedWithoutSizeChange,

  /// The change required element(s) to be added or removed from the collection.
  sizeChanged,

  /// No change was required (the operation ended in a no-op).
  noChangeRequired
}

typedef void _Freeze<K, V>(KeyValuePair<K, V> kv);

class _ImmutableHashMapIterator<K, V> implements Iterator<KeyValuePair<K, V>> {
  /// The builder being iterated, if applicable.
  final _ImmutableHashMapBuilder<K, V> _builder;

  /// The iterator over the map whose keys are hash values.
  _SortedIntKeyNodeIterator _mapIterator;

  /// The iterator in use within an individual [_HashBucket].
  _HashBucketIterator _bucketIterator;

  /// The version of the builder (when applicable) that is being iterated.
  int _iteratingBuilderVersion;

  _ImmutableHashMapIterator(_SortedIntKeyNode<_HashBucket<K, V>> root,
      [this._builder]) {
    _mapIterator = new _SortedIntKeyNodeIterator<_HashBucket<K, V>>(root);
    _iteratingBuilderVersion = _builder != null ? _builder.version : -1;
  }

  KeyValuePair<K, V> get current => _bucketIterator.current;

  bool moveNext() {
    throwIfChanged();

    if (_bucketIterator.moveNext()) {
      return true;
    }

    if (_mapIterator.moveNext()) {
      _bucketIterator = new _HashBucketIterator(_mapIterator.current.value);
      return _bucketIterator.moveNext();
    }

    return false;
  }

  void throwIfChanged() {
    if (_builder != null && _builder.version != _iteratingBuilderVersion) {
      throw new ConcurrentModificationError(this);
    }
  }
}

class _ImmutableHashMapIterable<K, V> extends IterableBase<KeyValuePair<K, V>> {
  final _ImmutableHashMapIterator _iterator;

  Iterator<KeyValuePair> get iterator => _iterator;

  _ImmutableHashMapIterable(_SortedIntKeyNode<_HashBucket<K, V>> root,
      _ImmutableHashMapBuilder<K, V> builder)
      : _iterator = new _ImmutableHashMapIterator(root, builder);
}

class _HashBucket<K, V> extends IterableBase<KeyValuePair<K, V>> {
  /// One of the values in this bucket.
  final KeyValuePair<K, V> _firstValue;

  /// Any other elements that hash to the same value.
  ///
  /// This is null if and only if the entire bucket is empty (including
  /// [_firstValue]). It's empty if [_firstValue] has an element but no
  /// additional elements.
  final _AvlNode<KeyValuePair<K, V>> _additionalElements;

  /// Returns `true` if this instance is empty.
  bool get isEmpty => _additionalElements == null;

  /// Returns `true` if this instance is not empty.
  bool get isNotEmpty => _additionalElements != null;

  KeyValuePair<K, V> get firstValue {
    if (isEmpty) {
      throw IterableElementError.noElement();
    }
    return _firstValue;
  }

  _AvlNode<KeyValuePair<K, V>> get additionalElements => _additionalElements;

  Iterator<KeyValuePair> get iterator => new _HashBucketIterator(this);

  _HashBucket.empty()
      : _firstValue = null,
        _additionalElements = null;

  _HashBucket(KeyValuePair<K, V> firstValue,
      [_AvlNode<KeyValuePair<K, V>> additionalElements])
      : _firstValue = firstValue,
        _additionalElements = additionalElements ?? _AvlNode.emptyNode;

  _HashBucket<K, V> add(
      K key,
      V value,
      EqualityComparator<KeyValuePair<K, V>> keyOnlyComparator,
      EqualityComparator<V> valueComparator,
      _KeyCollisionBehavior behavior,
      Out<_OperationResult> result) {
    final kv = new KeyValuePair<K, V>(key, value);
    if (isEmpty) {
      result.value = _OperationResult.sizeChanged;
      return new _HashBucket(kv);
    }
    if (keyOnlyComparator.equals(kv, _firstValue)) {
      switch (behavior) {
        case _KeyCollisionBehavior.setValue:
          result.value = _OperationResult.appliedWithoutSizeChange;
          return new _HashBucket(kv, _additionalElements);
        case _KeyCollisionBehavior.skip:
          result.value = _OperationResult.noChangeRequired;
          return this;
        case _KeyCollisionBehavior.throwIfValueDifferent:
          if (valueComparator.equals(_firstValue.value, value) != 0) {
            throw new ArgumentError('duplicate key: $key');
          }
          result.value = _OperationResult.noChangeRequired;
          return this;
        case _KeyCollisionBehavior.throwAlways:
          throw new ArgumentError('duplicate key: $key');
        default:
          throw new AssertionError();
      }
    }

    int keyCollisionIndex =
        _additionalElements._indexOf(kv, comparator: keyOnlyComparator);
    if (keyCollisionIndex < 0) {
      result.value = _OperationResult.sizeChanged;
      return new _HashBucket(_firstValue, _additionalElements.add(kv));
    } else {
      switch (behavior) {
        case _KeyCollisionBehavior.setValue:
          result.value = _OperationResult.appliedWithoutSizeChange;
          return new _HashBucket(_firstValue,
              _additionalElements.replaceAt(keyCollisionIndex, kv));
        case _KeyCollisionBehavior.skip:
          result.value = _OperationResult.noChangeRequired;
          return this;
        case _KeyCollisionBehavior.throwIfValueDifferent:
          final existingEntry = _additionalElements[keyCollisionIndex];
          if (!valueComparator.equals(existingEntry.value, value)) {
            throw new ArgumentError('duplicate key: $key');
          }
          result.value = _OperationResult.noChangeRequired;
          return this;
        case _KeyCollisionBehavior.throwAlways:
          throw new ArgumentError('duplicate key: $key');
        default:
          throw new AssertionError();
      }
    }
  }

  _HashBucket<K, V> remove(
      K key,
      EqualityComparator<KeyValuePair<K, V>> keyOnlyComparator,
      Out<_OperationResult> result) {
    if (isEmpty) {
      result.value = _OperationResult.noChangeRequired;
      return this;
    }

    final kv = new KeyValuePair<K, V>(key, null);
    if (keyOnlyComparator.equals(_firstValue, kv)) {
      if (_additionalElements.isEmpty) {
        result.value = _OperationResult.sizeChanged;
        return new _HashBucket.empty();
      } else {
        final indexOfRootNode = _additionalElements.left.length;
        result.value = _OperationResult.sizeChanged;
        return new _HashBucket(_additionalElements._key,
            _additionalElements.removeAt(indexOfRootNode));
      }
    }

    final index =
        _additionalElements._indexOf(kv, comparator: keyOnlyComparator);
    if (index < 0) {
      result.value = _OperationResult.noChangeRequired;
      return this;
    } else {
      result.value = _OperationResult.sizeChanged;
      return new _HashBucket(_firstValue, _additionalElements.removeAt(index));
    }
  }

  /// Gets the value for the given [key] in the collection if one exists.
  V tryGetValue(
      K key, EqualityComparator<KeyValuePair<K, V>> keyOnlyComparator) {
    if (isEmpty) {
      return null;
    }

    final kv = new KeyValuePair<K, V>(key, null);
    if (keyOnlyComparator.equals(_firstValue, kv)) {
      return _firstValue.value;
    }

    final index =
        _additionalElements._indexOf(kv, comparator: keyOnlyComparator);
    if (index < 0) {
      return null;
    }

    return _additionalElements[index].value;
  }

  /// Searches the map for a given [key] and returns the equal key it finds,
  /// if any.
  ///
  /// This can be useful when you want to reuse a previously stored reference
  /// instead of a newly constructed one (so that more sharing of references
  /// can occur) or to look up the canonical value, or a value that has more
  /// complete data than the value you currently have, although their
  /// comparator functions indicate they are equal.
  K tryGetKey(
      K equalKey, EqualityComparator<KeyValuePair<K, V>> keyOnlyComparator) {
    if (isEmpty) {
      return null;
    }

    final kv = new KeyValuePair<K, V>(equalKey, null);
    if (keyOnlyComparator.equals(_firstValue, kv)) {
      return _firstValue.key;
    }

    final index =
        _additionalElements._indexOf(kv, comparator: keyOnlyComparator);
    if (index < 0) {
      return null;
    }

    return _additionalElements[index].key;
  }

  void freeze() {
    if (_additionalElements != null) {
      _additionalElements.freeze();
    }
  }
}

enum _Position { beforeFirst, first, additional, end }

class _HashBucketIterator<K, V> implements Iterator<KeyValuePair<K, V>> {
  final _HashBucket<K, V> _bucket;

  _Position _currentPosition;

  Iterator<KeyValuePair<K, V>> _additionalIterator;

  KeyValuePair<K, V> get current {
    switch (_currentPosition) {
      case _Position.first:
        return _bucket.firstValue;
      case _Position.additional:
        return _additionalIterator.current;
      default:
        return null;
    }
  }

  bool moveNext() {
    if (_bucket.isEmpty) {
      _currentPosition = _Position.end;
      return false;
    }

    switch (_currentPosition) {
      case _Position.beforeFirst:
        _currentPosition = _Position.first;
        return true;
      case _Position.first:
        if (_bucket._additionalElements.isEmpty) {
          _currentPosition = _Position.end;
          return false;
        }

        _currentPosition = _Position.additional;
        _additionalIterator = _bucket._additionalElements.iterator;
        return _additionalIterator.moveNext();
      case _Position.additional:
        return _additionalIterator.moveNext();
      case _Position.end:
        return false;
      default:
        throw new AssertionError();
    }
  }

  _HashBucketIterator(this._bucket) : _currentPosition = _Position.beforeFirst;
}

/// Description of the current data structure as input into a mutating or
/// query method.
class _MutationInput<K, V> {
  final _SortedIntKeyNode<_HashBucket<K, V>> _root;
  final _Comparators _comparators;
  final int _length;

  _SortedIntKeyNode<_HashBucket<K, V>> get root => _root;
  EqualityComparator<K> get keyComparator => _comparators.keyComparator;
  EqualityComparator<KeyValuePair<K, V>> get keyOnlyComparator =>
      _comparators.keyOnlyComparator;
  EqualityComparator<V> get valueComparator => _comparators.valueComparator;
  EqualityComparator<_HashBucket<K, V>> get hashBucketComparator =>
      _comparators.hashBucketComparator;
  int get length => _length;

  _MutationInput(this._root, this._comparators, this._length);

  _MutationInput.from(ImmutableHashMap<K, V> map)
      : _root = map._root,
        _comparators = map._comparators,
        _length = map._length;
}

/// Describes the result of a mutation on the immutable data structure.
class _MutationResult<K, V> {
  _SortedIntKeyNode<_HashBucket<K, V>> _root;

  /// The number of elements added or removed from the collection
  /// as a result of the operation (a negative number represents removed
  /// elements).
  int _lengthAdjustment;

  _SortedIntKeyNode<_HashBucket<K, V>> get root => _root;

  int get lengthAdjustment => _lengthAdjustment;

  _MutationResult.from(_MutationInput unchangedInput)
      : _root = unchangedInput.root,
        _lengthAdjustment = 0;

  _MutationResult(
      _SortedIntKeyNode<_HashBucket<K, V>> root, int lengthAdjustment)
      : _root = checkNotNull(root),
        _lengthAdjustment = lengthAdjustment;

  ImmutableHashMap<K, V> finalize(ImmutableHashMap<K, V> priorMap) {
    checkNotNull(priorMap);
    return priorMap._wrap(_root, priorMap.length + _lengthAdjustment);
  }
}

class _KeyOnlyComparator<K, V>
    implements EqualityComparator<KeyValuePair<K, V>> {
  final EqualityComparator<K> _keyComparator;

  _KeyOnlyComparator(this._keyComparator);

  @override
  int getHashCode(KeyValuePair keyValuePair) =>
      _keyComparator.getHashCode(keyValuePair.key);

  @override
  bool equals(KeyValuePair x, KeyValuePair y) =>
      _keyComparator.equals(x.key, y.key);
}

class _Comparators<K, V> implements EqualityComparator<_HashBucket<K, V>> {
  static _Comparators defaultComparator = new _Comparators(
      EqualityComparator.defaultComparator,
      EqualityComparator.defaultComparator);

  final EqualityComparator<K> _keyComparator;
  final EqualityComparator<V> _valueComparator;
  final EqualityComparator<KeyValuePair<K, V>> _keyOnlyComparator;

  EqualityComparator<K> get keyComparator => _keyComparator;
  EqualityComparator<V> get valueComparator => _valueComparator;
  EqualityComparator<KeyValuePair<K, V>> get keyOnlyComparator =>
      _keyOnlyComparator;
  EqualityComparator<_HashBucket<K, V>> get hashBucketComparator => this;

  _Comparators(EqualityComparator<K> keyComparator,
      EqualityComparator<V> valueComparator)
      : _keyComparator = checkNotNull(keyComparator),
        _valueComparator = checkNotNull(valueComparator),
        _keyOnlyComparator = new _KeyOnlyComparator(keyComparator);

  @override
  bool equals(_HashBucket x, _HashBucket y) =>
      identical(x.additionalElements, y.additionalElements) &&
          keyComparator.equals(x.firstValue.key, y.firstValue.key) &&
          valueComparator.equals(x.firstValue.value, y.firstValue.value);

  @override
  int getHashCode(_HashBucket object) =>
      _keyComparator.getHashCode(object.firstValue.key);
}

class _ImmutableHashMapBuilder<K, V> extends MapBase<K, V>
    implements ImmutableMapBuilder<K, V> {
  _SortedIntKeyNode<_HashBucket<K, V>> _root = _SortedIntKeyNode.emptyNode;

  _Comparators<K, V> _comparators;

  int _length;

  /// Caches an immutable instance that represents the current state of
  /// the collection.
  ImmutableHashMap<K, V> _immutable;

  /// A number that increments every time the builder changes its contents.
  int _version;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  int get length => _length;

  int get version => _version;

  @override
  Iterable<K> get keys sync* {
    final iterable = new _ImmutableHashMapIterable(_root, this);
    for (final item in iterable) {
      yield item.key;
    }
  }

  @override
  Iterable<V> get values sync* {
    final iterable = new _ImmutableHashMapIterable(_root, this);
    for (final item in iterable) {
      yield item.value;
    }
  }

  _MutationInput get _origin =>
      new _MutationInput(_root, _comparators, _length);

  _ImmutableHashMapBuilder(ImmutableHashMap<K, V> map) {
    checkNotNull(map);

    _root = map._root;
    _length = map.length;
    _comparators = map._comparators;
    _immutable = map;
  }

  @override
  bool containsKey(Object key) => ImmutableHashMap._containsKey(key, _origin);

  @override
  bool containsValue(Object value) {
    final iterable = new _ImmutableHashMapIterable(_root, this);
    for (final item in iterable) {
      if (item.value == value) {
        return true;
      }
    }
    return false;
  }

  @override
  V operator [](Object key) {
    checkNotNull(key);
    return ImmutableHashMap._tryGetValue(key, _origin);
  }

  @override
  operator []=(K key, V value) {
    checkNotNull(key);

    final result = ImmutableHashMap._add(
        key, value, _KeyCollisionBehavior.setValue, _origin);
    _apply(result);
  }

  @override
  void addAll(Map<K, V> other) {
    checkNotNull(other);

    final pairs = zip([other.keys, other.values])
        .map((pair) => new KeyValuePair(pair[0], pair[1]));
    final result = ImmutableHashMap._addAll(
        pairs, _KeyCollisionBehavior.setValue, _origin);
    _apply(result);
  }

  @override
  V putIfAbsent(K key, V ifAbsent()) {
    var value = ImmutableHashMap._tryGetValue(key, _origin);
    if (value == null) {
      value = ifAbsent();
      final result = ImmutableHashMap._add(
          key, value, _KeyCollisionBehavior.setValue, _origin);
      _apply(result);
    }
    return value;
  }

  @override
  void forEach(void action(K key, V value)) {
    final iterable = new _ImmutableHashMapIterable(_root, this);
    for (final item in iterable) {
      action(item.key, item.value);
    }
  }

  @override
  V remove(Object key) {
    final value = ImmutableHashMap._tryGetValue(key, _origin);
    if (value != null) {
      final result = ImmutableHashMap._remove(key, _origin);
      _apply(result);
    }
    return value;
  }

  @override
  void clear() {
    _root = _SortedIntKeyNode.emptyNode;
    _length = 0;
  }

  @override
  ImmutableMap<K, V> toImmutable() {
    // Creating an instance of ImmutableHashMap<T> with our root node
    // automatically freezes our tree, ensuring that the returned instance
    // is immutable. Any further mutations made to this builder will clone
    // (and unfreeze) the spine of modified nodes until the next time
    // this method is invoked.
    if (_immutable == null) {
      _immutable = ImmutableHashMap.wrap(_root, _comparators, _length);
    }

    return _immutable;
  }

  /// Applies the result of some mutation operation to this instance.
  bool _apply(_MutationResult<K, V> result) {
    _root = result.root;
    _length += result.lengthAdjustment;
    return result.lengthAdjustment != 0;
  }
}

part of immutable;

abstract class ImmutableMap<K, V> {
  /// Gets the number of elements in the map.
  int get length;

  /// Returns `true` if this map is empty.
  bool get isEmpty;

  /// Returns `true` if this map is not empty.
  bool get isNotEmpty;

  /// Gets the keys in the map.
  Iterable<K> get keys;

  /// Gets the values in the values.
  Iterable<V> get values;

  /// Returns `true` if this map contains the given [key].
  ///
  /// Returns `true` if any of the keys in the map are equal to `key` according
  /// to the equality used by the map.
  bool containsKey(Object key);

  /// Returns `true` if this map contains the given [value].
  ////
  // Returns `true` if any of the values in the map are equal to `value`
  // according to the `==` operator.
  bool containsValue(Object value);

  /// Gets the empty instance.
  ImmutableMap<K, V> clear();

  /// Returns the value for the given [key] or `null` if [key] is not in the
  /// map.
  V operator[](K key);

  /// Associates the [key] with the given [value].
  ///
  /// If the key was already in the map, its associated value is changed.
  /// Otherwise the key-value pair is added to the map.
  ImmutableMap<K, V> add(K key, V value);

  /// Adds all key-value pairs of [other] to this map.
  ///
  /// If a key of [other] is already in this map, its value is overwritten.
  ImmutableMap<K, V> addAll(ImmutableMap<K, V> other);

  /// Removes [key] and its associated value, if present, from the map.
  ImmutableMap<K, V> remove(Object key);

  /// Creates a collection with the same contents as this collection that
  /// can be efficiently mutated across multiple operations using standard
  /// mutable interfaces.
  ///
  /// This is an O(1) operation and results in only a single (small) memory
  /// allocation.
  ImmutableMapBuilder<K, V> toBuilder();
}

abstract class ImmutableMapBuilder<K, V> implements Map<K, V> {
  ImmutableMap<K, V> toImmutable();
}

// Copyright (c) 2016, Kwang Yul Seo <kwangyul.seo@gmail.com>.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'hamt_immutable_map.dart';

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

  /// Creates an ImmutableMap instance with the default implementation.
  factory ImmutableMap.empty() => new HamtImmutableMap<K, V>.empty();

  /// Creates an ImmutableMap instance in which the keys and values are computed
  /// from the [iterable].
  ///
  /// For each element of the [iterable] this constructor computes a key-value
  /// pair, by applying [key] and [value] respectively.
  ///
  /// The example below creates a new ImmutableMap from a List. The keys of `map`
  /// are `list` values converted to strings, and the values of the `map` are the
  /// squares of the `list` values:
  ///
  ///     List<int> list = [1, 2, 3];
  ///     ImmutableMap<String, int> map = new ImmutableMap.fromIterable(list,
  ///         key: (item) => item.toString(),
  ///         value: (item) => item * item));
  ///
  ///     map['1'] + map['2']; // 1 + 4
  ///     map['3'] - map['2']; // 9 - 4
  ///
  /// If no values are specified for [key] and [value] the default is the
  /// identity function.
  ///
  /// In the following example, the keys and corresponding values of `map`
  /// are `list` values:
  ///
  ///     map = new ImmutableMap.fromIterable(list);
  ///     map[1] + map[2]; // 1 + 2
  ///     map[3] - map[2]; // 3 - 2
  ///
  /// The keys computed by the source [iterable] do not need to be unique. The
  /// last occurrence of a key will simply overwrite any previous value.
  factory ImmutableMap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) {
    throw new UnimplementedError();
  }

  /// Creates an ImmutableMap instance associating the given [keys] to [values].
  ///
  /// This constructor iterates over [keys] and [values] and maps each element of
  /// [keys] to the corresponding element of [values].
  ///
  ///     List<String> letters = ['b', 'c'];
  ///     List<String> words = ['bad', 'cat'];
  ///     ImmutableMap<String, String> map = new ImmutableMap.fromIterables(letters, words);
  ///     map['b'] + map['c'];  // badcat
  ///
  /// If [keys] contains the same object multiple times, the last occurrence
  /// overwrites the previous value.
  ///
  /// The two [Iterable]s must have the same length.
  factory ImmutableMap.fromIterables(Iterable<K> keys, Iterable<V> values) {
    throw new UnimplementedError();
  }

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

  /// Applies [f] to each key-value pair of the map.
  ///
  /// Calling `f` must not add or remove keys from the map.
  void forEach(void f(K key, V value));

  /// Returns the value for the given [key] or `null` if [key] is not in the
  /// map.
  V operator [](K key);

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

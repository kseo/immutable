part of immutable;

/// A [KeyValuePair] holds a key and a value from a map.
// It is used by the Iterable<T> implementation for ImmutableMap<TKey, TValue>.
class KeyValuePair<K, V> {
  final K key;
  final V value;

  KeyValuePair(this.key, this.value);

  @override
  String toString() => '[$key, $value]';
}

part of immutable._internal;

abstract class EqualityComparator<T> {
  static final EqualityComparator defaultComparator =
      new DefaultEqualityComparator();

  bool equals(T x, T y);

  int getHashCode(T object);
}

class DefaultEqualityComparator<T> implements EqualityComparator<T> {
  @override
  bool equals(T x, T y) => x == y;

  @override
  int getHashCode(T object) => object.hashCode;
}

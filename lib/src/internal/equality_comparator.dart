// Copyright (c) 2015, Kwang Yul Seo <kwangyul.seo@gmail.com>.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

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

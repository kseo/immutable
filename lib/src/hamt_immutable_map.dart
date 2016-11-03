// Copyright (c) 2016, Kwang Yul Seo <kwangyul.seo@gmail.com>.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:collection';

import 'immutable_map.dart';

class HamtImmutableMap<K, V> implements ImmutableMap<K, V> {
  static final HamtImmutableMap _empty =
      new HamtImmutableMap._internal(0, null, false, null);

  static final Object _notFound = new Object();

  @override
  final int length;

  final bool _hasNull;

  final V _nullValue;

  final Node<K, V> _root;

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length != 0;

  @override
  Iterable<K> get keys {
    throw new UnimplementedError();
  }

  @override
  Iterable<V> get values {
    throw new UnimplementedError();
  }

  factory HamtImmutableMap.empty() => _empty as HamtImmutableMap<K, V>;

  factory HamtImmutableMap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) {
    throw new UnimplementedError();
  }

  factory HamtImmutableMap.fromIterables(Iterable<K> keys, Iterable<V> values) {
    throw new UnimplementedError();
  }

  HamtImmutableMap._internal(
      this.length, this._root, this._hasNull, this._nullValue);

  @override
  V operator [](K key) {
    V notFound = null;
    if (key == null) return _hasNull ? _nullValue : notFound;
    return _root != null
        ? _root.find(0, key.hashCode, key, notFound)
        : notFound;
  }

  @override
  bool containsKey(Object key) {
    if (key == null) return _hasNull;
    return (_root != null)
        ? _root.find(0, key.hashCode, key as K, _notFound as V) != _notFound
        : false;
  }

  @override
  bool containsValue(Object value) {
    throw new UnimplementedError();
  }

  @override
  ImmutableMap<K, V> clear() => new HamtImmutableMap<K, V>.empty();

  @override
  void forEach(void f(K key, V value)) {
    throw new UnimplementedError();
  }

  @override
  ImmutableMap<K, V> add(K key, V value) {
    if (key == null) {
      if (_hasNull && value == _nullValue) return this;
      return new HamtImmutableMap._internal(
          _hasNull ? length : length + 1, _root, true, value);
    }
    Box addedLeaf = new Box(null);
    Node<K, V> newRoot =
        (_root == null ? new BitmapIndexedNode<K, V>.empty() : _root)
            .add(0, key.hashCode, key, value, addedLeaf);
    if (newRoot == _root) return this;
    return new HamtImmutableMap._internal(
        addedLeaf.value == null ? length : length + 1,
        newRoot,
        _hasNull,
        _nullValue);
  }

  @override
  ImmutableMap<K, V> addAll(ImmutableMap<K, V> other) {
    throw new UnimplementedError();
  }

  @override
  ImmutableMap<K, V> remove(Object key) {
    if (key == null) {
      return _hasNull
          ? new HamtImmutableMap._internal(length - 1, _root, false, null)
          : this;
    }
    if (_root == null) return this;
    Node<K, V> newRoot = _root.remove(0, key.hashCode, key as K);
    if (newRoot == _root) return this;
    return new HamtImmutableMap._internal(
        length - 1, newRoot, _hasNull, _nullValue);
  }

  @override
  ImmutableMapBuilder<K, V> toBuilder() {
    throw new UnimplementedError();
  }
}

class HamtImmutableMapBuilder<K, V> extends MapBase<K, V>
    implements ImmutableMapBuilder<K, V> {
  @override
  Iterable<K> get keys {
    throw new UnimplementedError();
  }

  ImmutableMap<K, V> toImmutable() {
    throw new UnimplementedError();
  }

  V operator [](Object key) {
    throw new UnimplementedError();
  }

  void operator []=(K key, V value) {
    throw new UnimplementedError();
  }

  @override
  void clear() {
    throw new UnimplementedError();
  }

  @override
  V remove(Object key) {
    throw new UnimplementedError();
  }
}

abstract class Node<K, V> {
  factory Node(int shift, K key1, V value1, int key2hash, K key2, V value2) {
    int key1hash = key1.hashCode;
    if (key1hash == key2hash)
      return new HashCollisionNode<K, V>(
          key1hash, 2, [key1, value1, key2, value2]);
    Box addedLeaf = new Box(null);
    return new BitmapIndexedNode<K, V>.empty()
        .add(shift, key1hash, key1, value1, addedLeaf)
        .add(shift, key2hash, key2, value2, addedLeaf);
  }

  Node<K, V> add(int shift, int hash, K key, V value, Box addedLeaf);

  Node<K, V> remove(int shift, int hash, K key);

  V find(int shift, int hash, K key, V notFound);
}

class BitmapIndexedNode<K, V> implements Node<K, V> {
  static BitmapIndexedNode _empty = new BitmapIndexedNode(0, []);

  final int bitmap;

  final List<Object> list;

  factory BitmapIndexedNode.empty() =>
      BitmapIndexedNode._empty as BitmapIndexedNode<K, V>;

  BitmapIndexedNode(this.bitmap, this.list);

  int _index(int bit) => _bitCount(bitmap & (bit - 1));

  @override
  Node<K, V> add(int shift, int hash, K key, V value, Box addedLeaf) {
    int bit = bitPos(hash, shift);
    int idx = _index(bit);
    if ((bitmap & bit) != 0) {
      final keyOrNull = list[2 * idx];
      final valueOrNode = list[2 * idx + 1];
      if (keyOrNull == null) {
        Node n = (valueOrNode as Node<K, V>)
            .add(shift + 5, hash, key, value, addedLeaf);
        if (n == valueOrNode) return this;
        return new BitmapIndexedNode(
            bitmap, cloneAndSet(list, 2 * idx + 1, n) as List<Node<K, V>>);
      }
      if (key == keyOrNull) {
        if (value == valueOrNode) return this;
        return new BitmapIndexedNode(
            bitmap, cloneAndSet(list, 2 * idx + 1, value) as List<Node<K, V>>);
      }
      addedLeaf.value = addedLeaf;
      return new BitmapIndexedNode(
          bitmap,
          cloneAndSet2(
              list,
              2 * idx,
              null,
              2 * idx + 1,
              new Node<K, V>(shift + 5, keyOrNull as K, valueOrNode as V, hash,
                  key, value)));
    } else {
      int n = _bitCount(bitmap);
      if (n >= 16) {
        final nodes = new List<Node<K, V>>(32);
        int jdx = mask(hash, shift);
        nodes[jdx] =
            (_empty as Node<K, V>).add(shift + 5, hash, key, value, addedLeaf);
        int j = 0;
        for (int i = 0; i < 32; i++) {
          if (((bitmap >> i) & 1) != 0) {
            if (list[j] == null)
              nodes[i] = list[j + 1] as Node<K, V>;
            else
              nodes[i] = (_empty as Node<K, V>).add(shift + 5, list[j].hashCode,
                  list[j] as K, list[j + 1] as V, addedLeaf);
            j += 2;
          }
        }
        return new ListNode(n + 1, nodes);
      } else {
        List newList = new List.from(list)..insertAll(2 * idx, [key, value]);
        addedLeaf.value = addedLeaf;
        return new BitmapIndexedNode<K, V>(bitmap | bit, newList);
      }
    }
  }

  @override
  Node<K, V> remove(int shift, int hash, K key) {
    int bit = bitPos(hash, shift);
    if ((bitmap & bit) == 0) return this;
    int idx = _index(bit);
    final keyOrNull = list[2 * idx];
    final valueOrNode = list[2 * idx + 1];
    if (keyOrNull == null) {
      Node n = (valueOrNode as Node<K, V>).remove(shift + 5, hash, key);
      if (n == valueOrNode) return this;
      if (n != null)
        return new BitmapIndexedNode<K, V>(
            bitmap, cloneAndSet(list, 2 * idx + 1, n) as List<Node<K, V>>);
      if (bitmap == bit) return null;
      return new BitmapIndexedNode<K, V>(bitmap ^ bit, removePair(list, idx));
    }
    if (key == keyOrNull) {
      // TODO: collapse
      return new BitmapIndexedNode<K, V>(bitmap ^ bit, removePair(list, idx));
    }
    return this;
  }

  @override
  V find(int shift, int hash, K key, V notFound) {
    int bit = bitPos(hash, shift);
    if ((bitmap & bit) == 0) return notFound;
    int idx = _index(bit);
    var keyOrNull = list[2 * idx];
    var valueOrNode = list[2 * idx + 1];
    if (keyOrNull == null)
      return (valueOrNode as Node<K, V>).find(shift + 5, hash, key, notFound);
    if (key == keyOrNull) return valueOrNode as V;
    return notFound;
  }
}

class ListNode<K, V> implements Node<K, V> {
  final int count;
  final List<Node<K, V>> list;

  ListNode(this.count, this.list);

  @override
  Node<K, V> add(int shift, int hash, K key, V value, Box addedLeaf) {
    int idx = mask(hash, shift);
    Node<K, V> node = list[idx];
    if (node == null) {
      return new ListNode<K, V>(
          count + 1,
          cloneAndSet(
              list,
              idx,
              new BitmapIndexedNode<K, V>.empty().add(
                  shift + 5, hash, key, value, addedLeaf)) as List<Node<K, V>>);
    }
    Node<K, V> n = node.add(shift + 5, hash, key, value, addedLeaf);
    if (n == node) return this;
    return new ListNode<K, V>(
        count, cloneAndSet(list, idx, n) as List<Node<K, V>>);
  }

  @override
  Node<K, V> remove(int shift, int hash, K key) {
    int idx = mask(hash, shift);
    Node<K, V> node = list[idx];
    if (node == null) return this;
    Node<K, V> n = node.remove(shift + 5, hash, key);
    if (n == node) return this;
    if (n == null) {
      if (count <= 8) // shrink
        return pack(idx);
      return new ListNode<K, V>(
          count - 1, cloneAndSet(list, idx, n) as List<Node<K, V>>);
    } else {
      return new ListNode<K, V>(
          count, cloneAndSet(list, idx, n) as List<Node<K, V>>);
    }
  }

  @override
  V find(int shift, int hash, K key, V notFound) {
    int idx = mask(hash, shift);
    Node<K, V> node = list[idx];
    if (node == null) return notFound;
    return node.find(shift + 5, hash, key, notFound);
  }

  Node<K, V> pack(int idx) {
    List<Node<K, V>> newList = new List<Node<K, V>>(2 * (count - 1));
    int j = 1;
    int bitmap = 0;
    for (int i = 0; i < idx; i++)
      if (list[i] != null) {
        newList[j] = list[i];
        bitmap |= 1 << i;
        j += 2;
      }
    for (int i = idx + 1; i < list.length; i++)
      if (list[i] != null) {
        newList[j] = list[i];
        bitmap |= 1 << i;
        j += 2;
      }
    return new BitmapIndexedNode(bitmap, newList);
  }
}

class HashCollisionNode<K, V> implements Node<K, V> {
  final int hash;
  final int count;
  final List list;

  HashCollisionNode(this.hash, this.count, this.list);

  @override
  Node<K, V> add(int shift, int hash, K key, V value, Box addedLeaf) {
    if (hash == this.hash) {
      int idx = findIndex(key);
      if (idx != -1) {
        if (list[idx + 1] == value) return this;
        return new HashCollisionNode(
            hash, count, cloneAndSet(list, idx + 1, value));
      }
      List newList = new List.from(list);
      newList[2 * count] = key;
      newList[2 * count + 1] = value;
      addedLeaf.value = addedLeaf;
      return new HashCollisionNode<K, V>(hash, count + 1, newList);
    }
    // nest it in a bitmap node
    return new BitmapIndexedNode<K, V>(bitPos(this.hash, shift), [null, this])
        .add(shift, hash, key, value, addedLeaf);
  }

  @override
  Node<K, V> remove(int shift, int hash, K key) {
    int idx = findIndex(key);
    if (idx == -1) return this;
    if (count == 1) return null;
    return new HashCollisionNode<K, V>(
        hash, count - 1, removePair(list, idx ~/ 2));
  }

  @override
  V find(int shift, int hash, K key, V notFound) {
    int idx = findIndex(key);
    if (idx < 0)
      return notFound;
    else
      return list[idx + 1] as V;
  }

  int findIndex(K key) {
    for (int i = 0; i < 2 * count; i += 2) {
      if (key == list[i]) return i;
    }
    return -1;
  }
}

int mask(int hash, int shift) => (hash >> shift) & 0x01f;

int bitPos(int hash, int shift) => 1 << mask(hash, shift);

List cloneAndSet(List list, int i, Object a) => new List.from(list)..[i] = a;

List cloneAndSet2(List list, int i, Object a, int j, Object b) =>
    new List.from(list)
      ..[i] = a
      ..[j] = b;

List removePair(List list, int i) => new List.from(list)..removeRange(i, i + 2);

class Box {
  Object value;
  Box(this.value);
}

// Assumes i is <= 32-bit.
int _bitCount(int i) {
  // See "Hacker's Delight", section 5-1, "Counting 1-Bits".

  // The basic strategy is to use "divide and conquer" to
  // add pairs (then quads, etc.) of bits together to obtain
  // sub-counts.
  //
  // A straightforward approach would look like:
  //
  // i = (i & 0x55555555) + ((i >>  1) & 0x55555555);
  // i = (i & 0x33333333) + ((i >>  2) & 0x33333333);
  // i = (i & 0x0F0F0F0F) + ((i >>  4) & 0x0F0F0F0F);
  // i = (i & 0x00FF00FF) + ((i >>  8) & 0x00FF00FF);
  // i = (i & 0x0000FFFF) + ((i >> 16) & 0x0000FFFF);
  //
  // The code below removes unnecessary &'s and uses a
  // trick to remove one instruction in the first line.

  i -= ((i >> 1) & 0x55555555);
  i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
  i = ((i + (i >> 4)) & 0x0F0F0F0F);
  i += (i >> 8);
  i += (i >> 16);
  return (i & 0x0000003F);
}

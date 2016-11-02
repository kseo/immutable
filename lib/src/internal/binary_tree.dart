// Copyright (c) 2015, Kwang Yul Seo <kwangyul.seo@gmail.com>.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of immutable._internal;

abstract class BinaryTree<E> {
  /// Gets the depth of the tree below this node.
  int get height;

  /// Gets a value indicating whether this node is empty.
  bool get isEmpty;

  /// Gets the number of non-empty nodes at this node and below.
  ///
  /// [UnsupportedError] is thrown if the implementation does not
  /// store this value at the node.
  int get length;

  /// Gets the value represented by the current node.
  E get value;

  /// Gets the left branch of this node.
  BinaryTree<E> get left;

  /// Gets the right branch of this node.
  BinaryTree<E> get right;
}
part of immutable;

class _SortedIntKeyNode<E> extends IterableBase<KeyValuePair<int, E>>
    implements
        BinaryTree<KeyValuePair<int, E>>,
        Iterable<KeyValuePair<int, E>> {
  static final _SortedIntKeyNode emptyNode = new _SortedIntKeyNode.empty();

  final int _key;

  final E _value;

  bool _frozen;

  /// The depth of the tree beneath this node.
  ///
  /// AVL tree height <= ~1.44 * log2(numNodes + 2)
  int _height;

  _SortedIntKeyNode<E> _left;

  _SortedIntKeyNode<E> _right;

  bool get isEmpty => _left == null;

  int get length => throw new UnsupportedError('length is not supported');

  int get height => _height;

  BinaryTree<KeyValuePair<int, E>> get left => _left;

  BinaryTree<KeyValuePair<int, E>> get right => _right;

  KeyValuePair<int, E> get value => new KeyValuePair<int, E>(_key, _value);

  Iterator<KeyValuePair<int, E>> get iterator =>
      new _SortedIntKeyNodeIterator(this);

  Iterable<KeyValuePair<int, E>> get values sync* {
    for (final pair in this) {
      yield pair.value;
    }
  }

  _SortedIntKeyNode.empty()
      : _frozen = true, // the empty node is *always* frozen.
        _key = null,
        _value = null,
        _height = 0;

  _SortedIntKeyNode(this._key, this._value, _SortedIntKeyNode<E> left,
      _SortedIntKeyNode<E> right,
      [bool frozen = false])
      : _left = checkNotNull(left),
        _right = checkNotNull(right),
        _frozen = frozen {
    assert(!frozen || (left._frozen && right._frozen));
    _height = 1 + max(left._height, right._height);
  }

  _SortedIntKeyNode<E> setItem(
      int key,
      E value,
      EqualityComparator<E> valueComparator,
      Out<bool> replacedExistingValue,
      Out<bool> mutated) {
    checkNotNull(valueComparator);

    return setOrAdd(
        key, value, valueComparator, true, replacedExistingValue, mutated);
  }

  _SortedIntKeyNode<E> remove(int key, Out<bool> mutated) {
    return _removeRecursive(key, mutated);
  }

  E getValueOrDefault(int key, E defaultValue()) {
    final match = _search(key);
    return match.isEmpty ? defaultValue() : match._value;
  }

  E tryGetValue(int key) {
    final match = _search(key);
    return match.isEmpty ? null : match._value;
  }

  /// Freezes this node and all descendant nodes so that any mutations require
  /// a new instance of the nodes.
  void freeze([_Freeze freezeFunction = null]) {
    // If this node is frozen, all its descendants must already be frozen.
    if (!_frozen) {
      if (freezeFunction != null) {
        freezeFunction(new KeyValuePair<int, E>(_key, _value));
      }

      _left.freeze();
      _right.freeze();
      _frozen = true;
    }
  }

  static _SortedIntKeyNode _rotateLeft(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    if (tree._right.isEmpty) {
      return tree;
    }

    final right = tree._right;
    return right._mutate(left: tree._mutate(right: right._left));
  }

  static _SortedIntKeyNode _rotateRight(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    if (tree._left.isEmpty) {
      return tree;
    }

    final left = tree._left;
    return left._mutate(right: tree._mutate(left: left._right));
  }

  static _SortedIntKeyNode _doubleLeft(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    if (tree._right.isEmpty) {
      return tree;
    }

    final rotatedRightChild = tree._mutate(right: _rotateRight(tree._right));
    return _rotateLeft(rotatedRightChild);
  }

  static _SortedIntKeyNode _doubleRight(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    if (tree._left.isEmpty) {
      return tree;
    }

    final rotatedLeftChild = tree._mutate(left: _rotateLeft(tree._left));
    return _rotateRight(rotatedLeftChild);
  }

  /// Returns a value indicating whether the tree is in balance.
  ///
  /// 0 if the tree is in balance, a positive integer if the right side is
  /// heavy, or a negative integer if the left side is heavy.
  static int _balance(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    return tree._right._height - tree._left._height;
  }

  static bool _isRightHeavy(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);
    return _balance(tree) >= 2;
  }

  static bool _isLeftHeavy(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);
    return _balance(tree) <= -2;
  }

  static _SortedIntKeyNode _makeBalanced(_SortedIntKeyNode tree) {
    checkNotNull(tree);
    assert(tree.isNotEmpty);

    if (_isRightHeavy(tree)) {
      return _balance(tree._right) < 0 ? _doubleLeft(tree) : _rotateLeft(tree);
    }

    if (_isLeftHeavy(tree)) {
      return _balance(tree._left) > 0 ? _doubleRight(tree) : _rotateRight(tree);
    }

    return tree;
  }

  /// Creates a node mutation, either by mutating this node (if not yet frozen)
  /// or by creating a clone of this node with the described changes.
  _SortedIntKeyNode<E> _mutate(
      {_SortedIntKeyNode<E> left: null, _SortedIntKeyNode<E> right: null}) {
    if (_frozen) {
      return new _SortedIntKeyNode<E>(
          _key, _value, left ?? _left, right ?? _right);
    } else {
      if (left != null) {
        _left = left;
      }

      if (right != null) {
        _right = right;
      }

      _height = 1 + max(_left._height, _right._height);
      return this;
    }
  }

  _SortedIntKeyNode<E> setOrAdd(
      int key,
      E value,
      EqualityComparator<E> valueComparator,
      bool overwriteExistingValue,
      Out<bool> replacedExistingValue,
      Out<bool> mutated) {
    // Arg validation skipped in this private method because it's recursive and
    // the tax of revalidating arguments on each recursive call is significant.
    // All our callers are therefore required to have done input validation.
    replacedExistingValue.value = false;
    if (isEmpty) {
      mutated.value = true;
      return new _SortedIntKeyNode<E>(key, value, this, this);
    } else {
      var result = this;
      if (key > _key) {
        final newRight = _right.setOrAdd(key, value, valueComparator,
            overwriteExistingValue, replacedExistingValue, mutated);
        if (mutated.value) {
          result = _mutate(right: newRight);
        }
      } else if (key < _key) {
        final newLeft = _left.setOrAdd(key, value, valueComparator,
            overwriteExistingValue, replacedExistingValue, mutated);
        if (mutated.value) {
          result = _mutate(left: newLeft);
        }
      } else {
        if (valueComparator.equals(_value, value)) {
          mutated.value = false;
          return this;
        } else if (overwriteExistingValue) {
          mutated.value = true;
          replacedExistingValue.value = true;
          result = new _SortedIntKeyNode<E>(key, value, _left, _right);
        } else {
          throw new ArgumentError('duplicate key $key');
        }
      }

      return mutated.value ? _makeBalanced(result) : result;
    }
  }

  /// Removes the specified key. Callers are expected to validate arguments.
  _SortedIntKeyNode<E> _removeRecursive(int key, Out<bool> mutated) {
    if (isEmpty) {
      mutated.value = false;
      return this;
    } else {
      var result = this;
      if (key == _key) {
        mutated.value = true;

        // If this is a leaf, just remove it
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
          while (successor._left.isNotEmpty) {
            successor = successor._left;
          }

          Out<bool> dummyMutated = new Out<bool>();
          final newRight = _right.remove(successor._key, dummyMutated);
          result = successor._mutate(left: _left, right: newRight);
        }
      } else if (key < _key) {
        final newLeft = _left.remove(key, mutated);
        if (mutated.value) {
          result = _mutate(left: newLeft);
        }
      } else {
        final newRight = _right.remove(key, mutated);
        if (mutated.value) {
          result = _mutate(right: newRight);
        }
      }

      return result.isEmpty ? result : _makeBalanced(result);
    }
  }

  /// Searches the specified key. Callers are expected to validate arguments.
  _SortedIntKeyNode<E> _search(int key) {
    if (isEmpty || key == _key) {
      return this;
    }

    if (key > _key) {
      return _right._search(key);
    }

    return _left._search(key);
  }
}

/// Iterates the contents of a binary tree.
class _SortedIntKeyNodeIterator<E> implements Iterator<KeyValuePair<int, E>> {
  _SortedIntKeyNode<E> _root;

  _SortedIntKeyNode<E> _current;

  Stack<_SortedIntKeyNode<E>> _stack;

  _SortedIntKeyNodeIterator(_SortedIntKeyNode<E> root)
      : _root = checkNotNull(root) {
    _current = null;
    _stack = new Stack<_SortedIntKeyNode>();
    if (!_root.isEmpty) {
      _pushLeft(_root);
    }
  }

  KeyValuePair<int, E> get current => _current?.value;

  bool moveNext() {
    if (_stack != null) {
      if (_stack.length > 0) {
        final n = _stack.pop();
        _current = n;
        _pushLeft(n.right);
        return true;
      }
    }

    _current = null;
    return false;
  }

  /// Pushes this node and all its left descendants onto the stack.
  void _pushLeft(_SortedIntKeyNode<E> node) {
    checkNotNull(node);
    while (node.isNotEmpty) {
      _stack.push(node);
      node = node.left;
    }
  }
}

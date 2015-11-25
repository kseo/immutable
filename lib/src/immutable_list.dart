part of immutable;

/// A list of elements that can only be modified by creating a new
/// instance of the list.
///
/// Mutations on this list generate new lists. Incremental changes to
/// a list share as much memory as possible with the prior versions of
/// a list, while allowing garbage collection to clean up any unique list
/// data that is no longer being referenced.
abstract class ImmutableList<E> implements Iterable<E> {
  /// An empty [ImmutableList].
  factory ImmutableList.empty() => new _AvlImmutableList<E>.empty();

  /// Creates a list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  factory ImmutableList.from(Iterable<E> elements) =>
      new _AvlImmutableList<E>.empty().addAll(elements);

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
  factory ImmutableListBuilder.empty() => new _AvlImmutableList<E>.empty().toBuilder();

  /// Creates a [ImmutableList] based on the contents of this instance.
  ImmutableList<E> toImmutable();
}


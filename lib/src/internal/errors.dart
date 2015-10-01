part of immutable._internal;

/// Creates errors throw by [Iterable] when the element count is wrong.
/// Copied from dart._internal library.
abstract class IterableElementError {
  /// Error thrown thrown by, e.g., [Iterable.first] when there is no result.
  static StateError noElement() => new StateError("No element");

  /// Error thrown by, e.g., [Iterable.single] if there are too many results.
  static StateError tooMany() => new StateError("Too many elements");

  /// Error thrown by, e.g., [List.setRange] if there are too few elements.
  static StateError tooFew() => new StateError("Too few elements");
}

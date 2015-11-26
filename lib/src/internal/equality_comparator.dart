part of immutable._internal;

/// The signature of a generic equality function.
///
/// [EqualityComparator] returns `true` if [a] is equal to [b].
typedef bool EqualityComparator<T>(T a, T b);

bool defaultEqualityComparator(dynamic a, dynamic b) => a == b;
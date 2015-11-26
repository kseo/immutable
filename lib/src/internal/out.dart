part of immutable._internal;

class Out<T> {
  T _value;

  T get value => _value;

  void set value(T value) {
    _value = value;
  }
}


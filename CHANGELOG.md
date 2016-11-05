# Changelog

## 0.0.4

* Add `ImmutableMap` and `ImmutableMapBuilder` class.
* Breaking change - remove `clear` method from `ImmutableList`. Use the
  `empty` constuctor instead.
* Breaking change - Remove `ImmutableListBuilder.empty`
  constructor. Call `toImmutable` on an empty `ImmutableList` instead.
* Turn on strong mode and fix warnings and errors.

## 0.0.3

* Add `ImmutableList` and `ImmutableListBuilder` class.
* Replace static `empty` fields with factory constructors.

## 0.0.2

* Add `ImmutableQueue` class.

## 0.0.1

* Add `ImmutableStack` class.

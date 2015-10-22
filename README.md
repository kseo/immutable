# immutable

Immutable collections for Dart. It's in its very early days and under heavy development,
not ready for production use.

## Usage

A simple usage example:

    import 'package:immutable/immutable.dart';

    main() {
      var stack = ImmutableStack.empty.push(5);
      print(stack.peek());
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kseo/immutable/issues

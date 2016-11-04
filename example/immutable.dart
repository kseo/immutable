// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library immutable.example;

import 'package:immutable/immutable.dart';

main() {
  var m = new ImmutableMap<int, String>.empty();
  m = m.add(1, 'a').add(2, 'b').add(3, 'c');
  print('m[1]: ${m[1]}');
  print('m[2]: ${m[2]}');
  print('m[3]: ${m[3]}');
  print('m[4]: ${m[4]}');
  print('m.length: ${m.length}');
  print('m.keys: ${m.keys}');
  print('m.values: ${m.values}');

  print('--- forEach ---');
  m.forEach((int key, String value) {
    print('key $key, value $value');
  });
  print('---------------');

  final b = m.toBuilder();
  b[5] = 'foo';
  b[6] = 'bar';
  print('b.remove(1): ${b.remove(1)}');
  print(b);

  m = b.toImmutable();
  print('m[1]: ${m[1]}');
  print('m[2]: ${m[2]}');
  print('m[3]: ${m[3]}');
  print('m[5]: ${m[5]}');
  print('m[6]: ${m[6]}');

  m = m.remove(1).remove(2);
  print('m[1]: ${m[1]}');
  print('m[2]: ${m[2]}');
  print('m[3]: ${m[3]}');
  print('m.length: ${m.length}');
  print('m.keys: ${m.keys}');
  print('m.values: ${m.values}');
}

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/core/utils/image_precache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a broken or missing image completes instead of throwing', () async {
    await expectLater(
      ImagePrecache.all([
        MemoryImage(Uint8List.fromList([0, 1, 2, 3])),
        const AssetImage('assets/does_not_exist.png'),
      ]),
      completes,
    );
  });
}

import 'dart:async';

import 'package:flutter/widgets.dart';

abstract final class ImagePrecache {
  static const _defaultTimeout = Duration(seconds: 2);

  static Future<void> all(
    Iterable<ImageProvider> providers, {
    Duration timeout = _defaultTimeout,
  }) {
    return Future.wait(providers.map((p) => one(p, timeout: timeout)));
  }

  static Future<void> one(
    ImageProvider provider, {
    Duration timeout = _defaultTimeout,
  }) {
    final completer = Completer<void>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;

    void done() {
      if (!completer.isCompleted) completer.complete();
      stream.removeListener(listener);
    }

    listener = ImageStreamListener((_, _) => done(), onError: (_, _) => done());
    stream.addListener(listener);

    return completer.future.timeout(timeout, onTimeout: done);
  }
}

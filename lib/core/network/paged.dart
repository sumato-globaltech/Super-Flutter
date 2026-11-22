import 'package:equatable/equatable.dart';

/// One page of a paginated list, as the API returns it:
/// {"data": [...], "meta": {"current_page", "per_page", "total", "last_page"}}.
class Paged<T> extends Equatable {
  const Paged({
    required this.items,
    this.page = 1,
    this.lastPage = 1,
    this.perPage = 0,
    this.total = 0,
  });

  /// Reads the envelope; a missing or malformed meta is one complete page.
  factory Paged.fromEnvelope(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> json) item,
  ) {
    final data = body['data'];
    final items = data is List
        ? data
              .whereType<Map>()
              .map((e) => item(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : List<T>.empty();
    final rawMeta = body['meta'];
    final meta = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : const <String, dynamic>{};
    int read(String key, int fallback) {
      final value = meta[key];
      if (value is int) return value;
      return int.tryParse('$value') ?? fallback;
    }

    return Paged(
      items: items,
      page: read('current_page', 1),
      lastPage: read('last_page', 1),
      perPage: read('per_page', items.length),
      total: read('total', items.length),
    );
  }

  final List<T> items;
  final int page;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMore => page < lastPage;

  int? get nextPage => hasMore ? page + 1 : null;

  bool get isEmpty => items.isEmpty;

  /// This page followed by [next], for "load more".
  Paged<T> append(Paged<T> next) => Paged(
    items: [...items, ...next.items],
    page: next.page,
    lastPage: next.lastPage,
    perPage: next.perPage,
    total: next.total,
  );

  @override
  List<Object?> get props => [items, page, lastPage, perPage, total];
}

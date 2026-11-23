import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/core/network/paged.dart';

class _Crop {
  _Crop(this.name);
  factory _Crop.fromJson(Map<String, dynamic> json) =>
      _Crop(json['name'] as String);
  final String name;
}

void main() {
  test('reads items and meta from the API envelope', () {
    final page = Paged.fromEnvelope({
      'success': true,
      'data': [
        {'name': 'Paddy'},
        {'name': 'Maize'},
      ],
      'meta': {
        'current_page': 1,
        'per_page': 2,
        'total': 5,
        'last_page': 3,
        'from': 1,
        'to': 2,
      },
      'links': {'next': 'http://dam.test/api/v1/crops?page=2'},
    }, _Crop.fromJson);

    expect(page.items.map((c) => c.name), ['Paddy', 'Maize']);
    expect(page.page, 1);
    expect(page.lastPage, 3);
    expect(page.perPage, 2);
    expect(page.total, 5);
    expect(page.hasMore, isTrue);
    expect(page.nextPage, 2);
  });

  test('the last page has no more', () {
    final page = Paged.fromEnvelope({
      'data': [
        {'name': 'Tea'},
      ],
      'meta': {'current_page': '3', 'last_page': '3'},
    }, _Crop.fromJson);

    expect(page.page, 3);
    expect(page.hasMore, isFalse);
    expect(page.nextPage, isNull);
  });

  test('without meta the data is one complete page', () {
    final page = Paged.fromEnvelope({
      'data': [
        {'name': 'Paddy'},
        'not an object',
      ],
    }, _Crop.fromJson);

    expect(page.items, hasLength(1));
    expect(page.total, 1);
    expect(page.hasMore, isFalse);
  });

  test('missing data is an empty page', () {
    final page = Paged.fromEnvelope({'meta': null}, _Crop.fromJson);

    expect(page.isEmpty, isTrue);
  });

  test('append adds the next page for load more', () {
    final first = Paged(items: const [1, 2], page: 1, lastPage: 2, total: 3);
    final second = Paged(items: const [3], page: 2, lastPage: 2, total: 3);

    final both = first.append(second);

    expect(both.items, [1, 2, 3]);
    expect(both.page, 2);
    expect(both.hasMore, isFalse);
    expect(both, Paged(items: const [1, 2, 3], page: 2, lastPage: 2, total: 3));
  });

  test('reads nested Laravel-style paginated envelope', () {
    final page = Paged.fromEnvelope({
      'success': true,
      'data': {
        'current_page': 1,
        'data': [
          {'name': 'Wheat'},
          {'name': 'Barley'},
        ],
        'per_page': 2,
        'total': 4,
        'last_page': 2,
      },
    }, _Crop.fromJson);

    expect(page.items.map((c) => c.name), ['Wheat', 'Barley']);
    expect(page.page, 1);
    expect(page.lastPage, 2);
    expect(page.perPage, 2);
    expect(page.total, 4);
    expect(page.hasMore, isTrue);
  });
}

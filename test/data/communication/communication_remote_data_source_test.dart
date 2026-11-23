import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';

class _Client extends Mock implements DioClient {}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final String body;
  RequestOptions? sent;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent = options;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CommunicationRemoteDataSource _source(_Adapter adapter) {
  final client = _Client();
  when(() => client.dio).thenReturn(
    Dio(BaseOptions(baseUrl: 'http://dam.test'))..httpClientAdapter = adapter,
  );
  return CommunicationRemoteDataSource(client);
}

// Samples as dam's resources return them.
const _alerts =
    r'''{"success":true,"message":"OK","data":[{"id":"01JALERT0000000000000000001","title":"Heavy rainfall","description":"Heavy rainfall expected in Jorhat district over the next 48 hours. Secure livestock and crops.","category":{"id":"01JCAT00000000000000000001","name":"Weather"},"district":{"id":"01JDIST0000000000000000001","name":"Jorhat"},"statewide":false,"severity":{"value":"warning","label":"Warning"},"starts_on":"2026-06-12","ends_on":"2026-06-14"}],"meta":{"current_page":1,"per_page":20,"from":1,"to":1,"total":1,"last_page":1},"links":{"first":"http://dam.test/api/v1/alerts?page=1","last":"http://dam.test/api/v1/alerts?page=1","prev":null,"next":null}}''';
const _notices =
    r'''{"success":true,"message":"OK","data":[{"id":"01JNOTICE000000000000000001","title":"Crop insurance enrolment open","category":{"id":"01JCAT00000000000000000002","name":"Schemes"},"priority":{"value":"high","label":"High"},"published_at":"2026-06-10T10:00:00+05:30","expires_at":"2026-07-10T23:59:59+05:30"}],"meta":{"current_page":1,"per_page":20,"from":1,"to":1,"total":1,"last_page":1},"links":{"first":null,"last":null,"prev":null,"next":null}}''';
const _notice =
    r'''{"success":true,"message":"OK","data":{"id":"01JNOTICE000000000000000001","title":"Crop insurance enrolment open","category":{"id":"01JCAT00000000000000000002","name":"Schemes"},"priority":{"value":"high","label":"High"},"published_at":"2026-06-10T10:00:00+05:30","expires_at":"2026-07-10T23:59:59+05:30","body":"<p>Enrol before <strong>10 July</strong> at your nearest office.</p>"}}''';
const _banners =
    r'''{"success":true,"message":"OK","data":[{"id":"01JBANNER000000000000000001","title":"Kharif seed subsidy","link_url":"https://agri.assam.gov.in/schemes","image_url":"https://dam.test/storage/banners/kharif.jpg","starts_on":"2026-06-01","ends_on":"2026-07-31"},{"id":"01JBANNER000000000000000002","title":"Soil health card camp","link_url":null,"image_url":"https://dam.test/storage/banners/soil.jpg","starts_on":"2026-06-10","ends_on":null}]}''';

void main() {
  test('alerts: a page, most severe first, for a district', () async {
    final adapter = _Adapter(_alerts);
    final page = await _source(adapter)
        .getAlerts(districtId: 'd1', page: 1, perPage: 5);

    expect(adapter.sent!.path, '/api/v1/alerts');
    expect(adapter.sent!.queryParameters, {
      'district_id': 'd1',
      'page': 1,
      'per_page': 5,
    });
    final alert = page.items.single;
    expect(alert.severity?.value, 'warning');
    expect(alert.district?.name, 'Jorhat');
    expect(alert.category?.name, 'Weather');
    expect(alert.statewide, isFalse);
    expect(page.hasMore, isFalse);
  });

  test('alerts without a district leave it out', () async {
    final adapter = _Adapter(_alerts);
    await _source(adapter).getAlerts(page: 1, perPage: 5);
    expect(adapter.sent!.queryParameters, {'page': 1, 'per_page': 5});
  });

  test('notices: a page; one notice has its body', () async {
    final list = await _source(_Adapter(_notices))
        .getNotices(page: 1, perPage: 3);
    expect(list.items.single.priority?.label, 'High');
    expect(
      list.items.single.publishedAt,
      DateTime.parse('2026-06-10T10:00:00+05:30'),
    );

    final adapter = _Adapter(_notice);
    final notice = await _source(adapter).getNotice('n1');
    expect(adapter.sent!.path, '/api/v1/notices/n1');
    expect(notice.body, contains('10 July'));
  });

  test('banners for a placement', () async {
    final adapter = _Adapter(_banners);
    final banners = await _source(adapter).getBanners(placement: 'home');
    expect(adapter.sent!.queryParameters, {'placement': 'home'});
    expect(banners.map((b) => b.title), [
      'Kharif seed subsidy',
      'Soil health card camp',
    ]);
    expect(banners.first.imageUrl, endsWith('kharif.jpg'));
    expect(banners.last.linkUrl, isNull);
  });
}

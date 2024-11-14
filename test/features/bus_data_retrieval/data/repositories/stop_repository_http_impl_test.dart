import 'package:b_stop/features/bus_data_retrieval/data/repositories/stop_repository_http_impl.dart';
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rust_core/rust_core.dart';

void main() {
  group('fetchAll', () {
    group('should return expected', () {
      for (final testCase in <({int status, dynamic receivedJson, Result<Iterable<Stop>, String> expected})>[
        (
          status: 404,
          receivedJson: <String, dynamic>{},
          expected: const Err('Unable to fetch all stops. Unexpected response code')
        ),
        (
          status: 200,
          receivedJson: <String, dynamic>{},
          expected: const Err('Unable to fetch all stops. Unexpected structure')
        ),
        (
          status: 200,
          receivedJson:
              'Vulputate condimentum efficitur nibh est pellentesque massa neque lectus eros quisque nascetur ligula laoreet sed natoque facilisis eleifend odio massa nisl sit ac eu suspendisse, integer dapibus. Nunc nibh ac metus non et sit varius urna dui faucibus proin, congue pellentesque magna, suspendisse libero tristique tempor lorem nisi sed nunc et imperdiet, aliquam dignissim gravida leo turpis. Nulla nam nibh suscipit sed platea ipsum magna arcu porttitor amet enim libero ac lectus ultricies, tempor dolor dapibus tellus ornare sed, neque lectus metus sed sem. Vitae turpis dictumst pellentesque dui vel imperdiet tortor pulvinar auctor condimentum velit nunc arcu lorem suspendisse.',
          expected: const Err('Unable to fetch all stops. Unexpected structure')
        ),
        (status: 200, receivedJson: null, expected: const Err('Unable to fetch all stops. No data received')),
        (status: 200, receivedJson: <()>[], expected: const Ok(<Stop>[])),
        (status: 200, receivedJson: [null, 12, 'chrome'], expected: const Ok(<Stop>[])),
        (
          status: 200,
          receivedJson: [
            {
              'stopId': '170A',
              'label': 'forest blocked',
              'stopLat': -56.85,
              'stopLon': 73.27,
            },
          ],
          expected: const Ok(
            [
              Stop(
                id: '170A',
                name: 'forest blocked',
                lat: -56.85,
                lon: 73.27,
              ),
            ],
          ),
        ),
        (
          status: 200,
          receivedJson: [
            90,
            {
              'stopId': '170A',
              'label': 'forest blocked',
              'stopLat': -56.85,
              'stopLon': 73.27,
            },
            'bryan',
            null,
          ],
          expected: const Ok(
            [
              Stop(
                id: '170A',
                name: 'forest blocked',
                lat: -56.85,
                lon: 73.27,
              ),
            ],
          ),
        ),
      ]) {
        final (:status, :receivedJson, :expected) = testCase;

        test('given $status response with $receivedJson then should return $expected', () async {
          final Dio dio = _buildDioClient();
          final DioAdapter dioAdapter = DioAdapter(dio: dio);
          final HttpStopsEndpoint stopsEndpoint = HttpStopsEndpoint(url: 'https://consumer.gov/notices');

          final StopRepository repository = StopRepositoryHttpImpl(dio, stopsEndpoint);

          dioAdapter.onGet(
            stopsEndpoint.url,
            (server) => server.reply(status, receivedJson),
          );

          final Result<Iter<Stop>, String> result = await repository.fetchAll();

          expect(result.isOk(), expected.isOk());
          switch (expected) {
            case Err(:final err):
              expect(result.unwrapErr(), equals(err));
            case Ok(:final ok):
              expect(result.unwrap(), equals(ok.iter()));
          }
        });
      }
    });
  });
}

Dio _buildDioClient() => Dio()..interceptors.add(PrettyDioLogger());

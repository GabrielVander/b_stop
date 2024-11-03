import 'package:b_stop/core/logging/b_stop_logger.dart' show BStopLogger;
import 'package:b_stop/core/logging/b_stop_logger_factory.dart' show BStopLoggerFactory;
import 'package:b_stop/core/utils/cast.dart' show cast;
import 'package:b_stop/features/bus_data_retrieval/data/models/stop_http_model.dart' show StopHttpModel;
import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart' show Stop;
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart' show StopRepository;
import 'package:dio/dio.dart' show Dio, Options, Response;
import 'package:rust_core/rust_core.dart'
    show Err, FutureResult, FutureResultExtension, Iter, IterableExtension, Ok, Result;

class StopRepositoryHttpImpl implements StopRepository {
  StopRepositoryHttpImpl(
    Dio dioClient,
    HttpStopsEndpoint stopsEndpoint,
  )   : _dioClient = dioClient,
        _stopsEndpoint = stopsEndpoint;

  final BStopLogger _logger = BStopLoggerFactory.standard();
  final Dio _dioClient;
  final HttpStopsEndpoint _stopsEndpoint;

  @override
  FutureResult<Iter<Stop>, String> fetchAll() async => FutureResult.value(const Ok('Fetching all stops...'))
      .inspect(_logger.info)
      .andThen((_) => _makeHttpRequest())
      .andThen(_checkResponseStatus)
      .map(_retrieveResponseBody)
      .andThen(_checkResponseBody)
      .andThen(_parseResponseBody)
      .map(_parseAsStopIterable)
      .mapErr((e) => 'Unable to fetch all stops. $e')
      .inspectErr(_logger.warning);

  FutureResult<Response<Object?>, String> _makeHttpRequest() async => Ok<Response<Object?>, String>(
        await _dioClient.get<Object>(
          _stopsEndpoint.buildFullUrl(),
          queryParameters: _stopsEndpoint.buildQueryParameters(),
          options: Options(validateStatus: (_) => true),
        ),
      ).inspect((r) => _logger.debug('Received response: $r'));

  Result<Response<Object?>, String> _checkResponseStatus(Response<Object?> response) {
    if (response.statusCode == 200) {
      return Ok(response);
    }

    _logger.error('Received an unexpected response code: ${response.statusCode}');
    return const Err('Unexpected response code');
  }

  Object? _retrieveResponseBody(Response<Object?> response) => response.data;

  Result<Object, String> _checkResponseBody(Object? data) {
    if (data != null) {
      return Ok(data);
    }

    _logger.error('Received null response body');
    return const Err('No data received');
  }

  Result<Iter<Map<String, dynamic>>, String> _parseResponseBody(Object body) =>
      _parseAsIterable(body).map(_parseAsJsonIterable);

  Result<Iter<dynamic>, String> _parseAsIterable(Object body) => cast<List<dynamic>>(body)
      .map((i) => i.iter())
      .inspectErr((e) => _logger.error('Unable to parse response body as iterable: $e'))
      .mapErr((_) => 'Unexpected structure');

  Iter<Map<String, dynamic>> _parseAsJsonIterable(Iter<dynamic> iterable) =>
      iterable.map(_parseAsJson).where((parseResult) => parseResult.isOk()).map((parseResult) => parseResult.unwrap());

  Result<Map<String, dynamic>, String> _parseAsJson(dynamic element) => cast<Map<String, dynamic>>(element)
      .inspectErr((e) => _logger.warning('Unable to parse element from list: $e. Skipping...'));

  Iter<Stop> _parseAsStopIterable(Iter<Map<String, dynamic>> jsonIter) => jsonIter.map(_parseAsStopEntity);

  Stop _parseAsStopEntity(Map<String, dynamic> json) => StopHttpModel.fromJson(json).toEntity();
}

final class HttpBaseInformation {
  HttpBaseInformation({
    required this.baseUrl,
    required this.projectId,
    required this.projectHash,
  });

  final String baseUrl;
  final String projectId;
  final String projectHash;
}

abstract interface class UrlBuilder {
  String buildFullUrl();
}

abstract interface class QueryParametersBuilder {
  Map<String, dynamic> buildQueryParameters();
}

sealed class HttpEndpoint implements UrlBuilder, QueryParametersBuilder {
  HttpEndpoint({required this.httpBaseInfo, required this.endpoint});

  final HttpBaseInformation httpBaseInfo;
  final String endpoint;
}

final class HttpStopsEndpoint extends HttpEndpoint {
  HttpStopsEndpoint({required super.httpBaseInfo, required super.endpoint});

  @override
  String buildFullUrl() {
    return '${httpBaseInfo.baseUrl}$endpoint';
  }

  @override
  Map<String, dynamic> buildQueryParameters() {
    return {'project_hash': httpBaseInfo.projectHash};
  }
}

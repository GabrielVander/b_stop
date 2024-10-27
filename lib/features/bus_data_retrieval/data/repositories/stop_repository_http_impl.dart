import 'package:b_stop/core/logging/b_stop_logger.dart';
import 'package:b_stop/core/logging/b_stop_logger_factory.dart';
import 'package:b_stop/core/utils/cast.dart';
import 'package:b_stop/features/bus_data_retrieval/data/models/stop_http_model.dart';
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart';
import 'package:dio/dio.dart' show Dio, Options, Response;
import 'package:rust_core/rust_core.dart' show Err, FutureResult, FutureResultExtension, Ok, Result;

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
  FutureResult<List<Stop>, String> fetchAll() async =>
      FutureResult<String, String>.value(const Ok<String, String>('Fetching all stops...'))
          .inspect(_logger.info)
          .andThen<Response<Object?>>((String _) => _makeHttpRequest())
          .andThen<Response<Object?>>(_checkResponseStatus)
          .map<Object?>(_retrieveResponseBody)
          .andThen<Object>(_checkResponseBody)
          .andThen<List<Map<String, dynamic>>>(_parseResponseBody)
          .map<List<Stop>>(_parseAsStopIterable)
          .mapErr<String>((String e) => 'Unable to fetch all stops. $e')
          .inspectErr(_logger.warning);

  FutureResult<Response<Object?>, String> _makeHttpRequest() async => Ok<Response<Object?>, String>(
        await _dioClient.get<Object>(
          _stopsEndpoint.buildFullUrl(),
          queryParameters: _stopsEndpoint.buildQueryParameters(),
          options: Options(validateStatus: (int? _) => true),
        ),
      ).inspect((Response<Object?> r) => _logger.debug('Received response: $r'));

  Result<Response<Object?>, String> _checkResponseStatus(Response<Object?> response) {
    if (response.statusCode == 200) {
      return Ok<Response<Object?>, String>(response);
    }

    _logger.error('Received an unexpected response code: ${response.statusCode}');
    return const Err<Response<Object?>, String>('Unexpected response code');
  }

  Object? _retrieveResponseBody(Response<Object?> response) => response.data;

  Result<Object, String> _checkResponseBody(Object? data) {
    if (data != null) {
      return Ok<Object, String>(data);
    }

    _logger.error('Received null response body');
    return const Err<Object, String>('No data received');
  }

  Result<List<Map<String, dynamic>>, String> _parseResponseBody(Object body) =>
      _parseAsIterable(body).map<List<Map<String, dynamic>>>(_parseAsJsonIterable);

  Result<List<dynamic>, String> _parseAsIterable(Object body) => cast<List<dynamic>>(body)
      .inspectErr((String e) => _logger.error('Unable to parse response body as iterable: $e'))
      .mapErr<String>((String _) => 'Unexpected structure');

  List<Map<String, dynamic>> _parseAsJsonIterable(List<dynamic> iterable) => iterable
      .map<Result<Map<String, dynamic>, String>>(_parseAsJson)
      .toList()
      .where((Result<Map<String, dynamic>, String> parseResult) => parseResult.isOk())
      .map<Map<String, dynamic>>(
        (Result<Map<String, dynamic>, String> parseResult) => parseResult.unwrap(),
      )
      .toList();

  Result<Map<String, dynamic>, String> _parseAsJson(dynamic element) =>
      cast<Map<String, dynamic>>(element).inspectErr(
        (String e) => _logger.warning('Unable to parse element from list: $e. Skipping...'),
      );

  List<Stop> _parseAsStopIterable(List<Map<String, dynamic>> jsonIter) =>
      jsonIter.map<Stop>(_parseAsStopEntity).toList();

  Stop _parseAsStopEntity(Map<String, dynamic> json) => StopHttpModel.fromJson(json).toEntity();
}

final class HttpBaseInformation {
  HttpBaseInformation({required this.baseUrl, required this.projectId, required this.projectHash});

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

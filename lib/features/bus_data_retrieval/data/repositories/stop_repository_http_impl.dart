import 'package:b_stop/core/utils/cast.dart';
import 'package:b_stop/features/bus_data_retrieval/data/models/stop_http_model.dart';
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart';
import 'package:dio/dio.dart' show Dio, Options, Response;
import 'package:rust_core/rust_core.dart' show Err, FutureResult, Ok, Result;

class StopRepositoryHttpImpl implements StopRepository {
  StopRepositoryHttpImpl(
    Dio dioClient,
    HttpStopsEndpoint stopsEndpoint,
  )   : _dioClient = dioClient,
        _stopsEndpoint = stopsEndpoint;

  final Dio _dioClient;
  final HttpStopsEndpoint _stopsEndpoint;

  @override
  FutureResult<List<Stop>, String> fetchAll() async => (await _makeHttpRequest())
      .andThen<Response<Object?>>(_checkResponseStatus)
      .map<Object?>(_retrieveResponseBody)
      .andThen<Object>(_checkResponseBody)
      .andThen<List<Map<String, dynamic>>>(_parseResponseBody)
      .map<List<Stop>>(_parseAsStopIterable)
      .mapErr((e) => 'Unable to fetch all stops. $e');

  FutureResult<Response<Object?>, String> _makeHttpRequest() async => Ok<Response<Object?>, String>(
        await _dioClient.get<Object>(
          _stopsEndpoint.buildFullUrl(),
          queryParameters: _stopsEndpoint.buildQueryParameters(),
          options: Options(validateStatus: (int? _) => true),
        ),
      );

  Result<Response<Object?>, String> _checkResponseStatus(Response<Object?> response) =>
      response.statusCode == 200
          ? Ok<Response<Object?>, String>(response)
          : const Err<Response<Object?>, String>('Unexpected response code');

  Object? _retrieveResponseBody(Response<Object?> response) => response.data;

  Result<Object, String> _checkResponseBody(Object? data) =>
      data != null ? Ok<Object, String>(data) : const Err<Object, String>('No data received');

  Result<List<Map<String, dynamic>>, String> _parseResponseBody(Object body) =>
      _parseAsIterable(body).map<List<Map<String, dynamic>>>(_parseAsJsonIterable);

  Result<List<dynamic>, String> _parseAsIterable(Object body) =>
      cast<List<dynamic>>(body).mapErr<String>((String _) => 'Unexpected structure');

  List<Map<String, dynamic>> _parseAsJsonIterable(List<dynamic> iterable) => iterable
      .map<Result<Map<String, dynamic>, String>>(cast<Map<String, dynamic>>)
      .toList()
      .where((Result<Map<String, dynamic>, String> parseResult) => parseResult.isOk())
      .map<Map<String, dynamic>>(
        (Result<Map<String, dynamic>, String> parseResult) => parseResult.unwrap(),
      )
      .toList();

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

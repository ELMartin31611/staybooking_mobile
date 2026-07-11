import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/tarifa_habitacion.dart';
import '../../../domain/model/temporada.dart';

class RateRemoteDataSource {
  RateRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Temporada>> getTemporadas({
    bool? isActive,
    String? search,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.temporadas,
      queryParameters: _cleanQueryParameters({
        'is_active': isActive,
        'search': search,
        'page_size': 100,
      }),
    );

    final results = _extractResults(response.data);

    return results.map(Temporada.fromJson).toList(growable: false);
  }

  Future<Temporada> getTemporadaById(int id) async {
    final response = await _dio.get<dynamic>(
      '${ApiEndpoints.temporadas}$id/',
    );

    return Temporada.fromJson(
      _extractObject(response.data),
    );
  }

  Future<List<TarifaHabitacion>> getTarifasHabitacion({
    int? tipoHabitacionId,
    int? temporadaId,
    bool? isActive,
    String? moneda,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.tarifasHabitacion,
      queryParameters: _cleanQueryParameters({
        'tipo_habitacion': tipoHabitacionId,
        'temporada': temporadaId,
        'is_active': isActive,
        'moneda': moneda,
        'page_size': 100,
      }),
    );

    final results = _extractResults(response.data);

    return results.map(TarifaHabitacion.fromJson).toList(growable: false);
  }

  Future<TarifaHabitacion> getTarifaHabitacionById(int id) async {
    final response = await _dio.get<dynamic>(
      '${ApiEndpoints.tarifasHabitacion}$id/',
    );

    return TarifaHabitacion.fromJson(
      _extractObject(response.data),
    );
  }

  Map<String, dynamic> _cleanQueryParameters(
    Map<String, dynamic> parameters,
  ) {
    final cleanedParameters = Map<String, dynamic>.from(parameters);

    cleanedParameters.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;

      return false;
    });

    return cleanedParameters;
  }

  List<Map<String, dynamic>> _extractResults(dynamic data) {
    final dynamic results;

    if (data is Map<String, dynamic>) {
      results = data['results'];
    } else {
      results = data;
    }

    if (results is! List) {
      throw const FormatException(
        'La API no devolvió un listado válido.',
      );
    }

    return results.map<Map<String, dynamic>>((item) {
      if (item is! Map) {
        throw const FormatException(
          'La API devolvió un elemento inválido.',
        );
      }

      return Map<String, dynamic>.from(item);
    }).toList(growable: false);
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'La API no devolvió un objeto válido.',
      );
    }

    return Map<String, dynamic>.from(data);
  }
}

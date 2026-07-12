import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/huesped_reserva.dart';
import '../../../domain/model/reserva.dart';
import '../../../domain/model/reserva_habitacion.dart';

class ReservationRemoteDataSource {
  ReservationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Reserva>> getReservas({
    ReservaEstado? estado,
    int? clienteId,
    String? search,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.reservas,
      queryParameters: _cleanQueryParameters({
        'estado': estado?.apiValue,
        'cliente': clienteId,
        'search': search,
        'page_size': 100,
      }),
    );

    return _extractResults(response.data)
        .map(Reserva.fromJson)
        .toList(growable: false);
  }

  Future<Reserva> getReservaById(int id) async {
    final response = await _dio.get<dynamic>(
      '${ApiEndpoints.reservas}$id/',
    );

    return Reserva.fromJson(_extractObject(response.data));
  }

  Future<Reserva> createReserva(ReservaRequest request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.reservas,
      data: request.toJson(),
    );

    return Reserva.fromJson(_extractObject(response.data));
  }

  Future<Reserva> updateReserva(int id, ReservaRequest request) async {
    final response = await _dio.put<dynamic>(
      '${ApiEndpoints.reservas}$id/',
      data: request.toJson(),
    );

    return Reserva.fromJson(_extractObject(response.data));
  }

  Future<Reserva> updateReservaEstado(
    int id,
    ReservaEstado estado,
  ) async {
    final response = await _dio.patch<dynamic>(
      '${ApiEndpoints.reservas}$id/',
      data: {'estado': estado.apiValue},
    );

    return Reserva.fromJson(_extractObject(response.data));
  }

  Future<void> deleteReserva(int id) async {
    await _dio.delete<dynamic>(
      '${ApiEndpoints.reservas}$id/',
    );
  }

  Future<List<ReservaHabitacion>> getReservaHabitaciones({
    required int reservaId,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.reservaHabitaciones,
      queryParameters: {
        'reserva': reservaId,
        'page_size': 100,
      },
    );

    return _extractResults(response.data)
        .map(ReservaHabitacion.fromJson)
        .toList(growable: false);
  }

  Future<ReservaHabitacion> createReservaHabitacion(
    ReservaHabitacionRequest request,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.reservaHabitaciones,
      data: request.toJson(),
    );

    return ReservaHabitacion.fromJson(
      _extractObject(response.data),
    );
  }

  Future<void> deleteReservaHabitacion(int id) async {
    await _dio.delete<dynamic>(
      '${ApiEndpoints.reservaHabitaciones}$id/',
    );
  }

  Future<List<HuespedReserva>> getHuespedesReserva({
    required int reservaId,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.huespedesReserva,
      queryParameters: {
        'reserva': reservaId,
        'page_size': 100,
      },
    );

    return _extractResults(response.data)
        .map(HuespedReserva.fromJson)
        .toList(growable: false);
  }

  Future<HuespedReserva> createHuespedReserva(
    HuespedReservaRequest request,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.huespedesReserva,
      data: request.toJson(),
    );

    return HuespedReserva.fromJson(
      _extractObject(response.data),
    );
  }

  Future<HuespedReserva> updateHuespedReserva(
    int id,
    HuespedReservaRequest request,
  ) async {
    final response = await _dio.put<dynamic>(
      '${ApiEndpoints.huespedesReserva}$id/',
      data: request.toJson(),
    );

    return HuespedReserva.fromJson(
      _extractObject(response.data),
    );
  }

  Future<void> deleteHuespedReserva(int id) async {
    await _dio.delete<dynamic>(
      '${ApiEndpoints.huespedesReserva}$id/',
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

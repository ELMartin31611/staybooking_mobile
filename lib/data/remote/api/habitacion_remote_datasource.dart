import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/habitacion.dart';

class HabitacionRemoteDatasource {
  final Dio dio;

  const HabitacionRemoteDatasource({
    required this.dio,
  });

  Future<PaginatedHabitaciones> getHabitaciones({
    int page = 1,
    int? hotelId,
    int? tipoHabitacionId,
    String? estado,
    bool? disponible,
    String? search,
  }) async {
    final response = await dio.get(
      ApiEndpoints.habitaciones,
      queryParameters: {
        'page': page,
        if (hotelId != null) 'hotel': hotelId,
        if (tipoHabitacionId != null) 'tipo_habitacion': tipoHabitacionId,
        if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
        if (disponible != null) 'disponible': disponible,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = response.data;

    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => Habitacion.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PaginatedHabitaciones(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      return PaginatedHabitaciones.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de habitaciones',
    );
  }

  Future<Habitacion> getHabitacionById(int id) async {
    final response = await dio.get(
      '${ApiEndpoints.habitaciones}$id/',
    );

    final data = response.data;

    if (data is Map) {
      return Habitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de la habitación',
    );
  }
}

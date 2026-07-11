import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/tipo_habitacion.dart';

class TipoHabitacionRemoteDatasource {
  final Dio dio;

  const TipoHabitacionRemoteDatasource({
    required this.dio,
  });

  Future<PaginatedTiposHabitacion> getTiposHabitacion({
    int page = 1,
    int? hotelId,
    String? search,
  }) async {
    final response = await dio.get(
      ApiEndpoints.tiposHabitacion,
      queryParameters: {
        'page': page,
        if (hotelId != null) 'hotel': hotelId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = response.data;

    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => TipoHabitacion.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PaginatedTiposHabitacion(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      return PaginatedTiposHabitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de tipos de habitación',
    );
  }

  Future<TipoHabitacion> getTipoHabitacionById(
    int id,
  ) async {
    final response = await dio.get(
      '${ApiEndpoints.tiposHabitacion}$id/',
    );

    final data = response.data;

    if (data is Map) {
      return TipoHabitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida del tipo de habitación',
    );
  }
}

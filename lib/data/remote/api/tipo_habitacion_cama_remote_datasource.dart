import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/tipo_habitacion_cama.dart';

class TipoHabitacionCamaRemoteDatasource {
  final Dio dio;

  const TipoHabitacionCamaRemoteDatasource({
    required this.dio,
  });

  Future<PaginatedTiposHabitacionCama> getTiposHabitacionCama({
    int page = 1,
    int? tipoHabitacionId,
    int? camaId,
  }) async {
    final response = await dio.get(
      ApiEndpoints.tiposHabitacionCamas,
      queryParameters: {
        'page': page,
        if (tipoHabitacionId != null) 'tipo_habitacion': tipoHabitacionId,
        if (camaId != null) 'cama': camaId,
      },
    );

    final data = response.data;

    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => TipoHabitacionCama.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PaginatedTiposHabitacionCama(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      return PaginatedTiposHabitacionCama.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de tipos de habitación y camas',
    );
  }

  Future<TipoHabitacionCama> getTipoHabitacionCamaById(int id) async {
    final response = await dio.get(
      '${ApiEndpoints.tiposHabitacionCamas}$id/',
    );

    final data = response.data;

    if (data is Map) {
      return TipoHabitacionCama.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida del tipo de habitación y cama',
    );
  }
}

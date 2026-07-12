import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/imagen_habitacion.dart';

class ImagenHabitacionRemoteDatasource {
  final Dio dio;

  const ImagenHabitacionRemoteDatasource({
    required this.dio,
  });

  Future<PaginatedImagenesHabitacion> getImagenesHabitacion({
    int page = 1,
    int? habitacionId,
  }) async {
    final response = await dio.get(
      ApiEndpoints.imagenesHabitacion,
      queryParameters: {
        'page': page,
        if (habitacionId != null) 'habitacion': habitacionId,
      },
    );

    final data = response.data;

    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => ImagenHabitacion.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PaginatedImagenesHabitacion(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      return PaginatedImagenesHabitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de imágenes de habitación',
    );
  }

  Future<ImagenHabitacion> getImagenHabitacionById(
    int id,
  ) async {
    final response = await dio.get(
      '${ApiEndpoints.imagenesHabitacion}$id/',
    );

    final data = response.data;

    if (data is Map) {
      return ImagenHabitacion.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de la imagen de habitación',
    );
  }
}

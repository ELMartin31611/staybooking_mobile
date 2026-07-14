import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/imagen_habitacion.dart';

class ImagenHabitacionRemoteDatasource {
  const ImagenHabitacionRemoteDatasource({
    required this.dio,
  });

  final Dio dio;

  Future<PaginatedImagenesHabitacion>
      getImagenesHabitacion({
    int page = 1,
    int? habitacionId,
  }) async {
    final response = await dio.get(
      ApiEndpoints.imagenesHabitacion,
      queryParameters: {
        'page': page,
        'page_size': 100,
        if (habitacionId != null)
          'habitacion': habitacionId,
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
      'Respuesta inválida de imágenes de habitación.',
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
      'Respuesta inválida de la imagen de habitación.',
    );
  }

  Future<ImagenHabitacion> uploadImagenHabitacion({
    required int habitacionId,
    required XFile image,
    required String titulo,
    String descripcion = '',
    int orden = 0,
    bool esPrincipal = false,
  }) async {
    final bytes = await image.readAsBytes();

    final formData = FormData.fromMap({
      'habitacion': habitacionId.toString(),
      'imagen': MultipartFile.fromBytes(
        bytes,
        filename: image.name,
      ),
      'titulo': titulo,
      'descripcion': descripcion,
      'orden': orden.toString(),
      'es_principal': esPrincipal.toString(),
    });

    final response = await dio.post(
      ApiEndpoints.imagenesHabitacion,
      data: formData,
    );

    if (response.data is Map) {
      return ImagenHabitacion.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    }

    throw const FormatException(
      'El servidor no devolvió la imagen creada.',
    );
  }
}
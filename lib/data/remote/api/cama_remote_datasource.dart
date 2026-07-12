import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/cama.dart';

class CamaRemoteDatasource {
  final Dio dio;

  const CamaRemoteDatasource({
    required this.dio,
  });

  Future<PaginatedCamas> getCamas({
    int page = 1,
    String? search,
    String? estado,
  }) async {
    final response = await dio.get(
      ApiEndpoints.camas,
      queryParameters: {
        'page': page,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
      },
    );

    final data = response.data;

    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => Cama.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PaginatedCamas(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      return PaginatedCamas.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de camas',
    );
  }

  Future<Cama> getCamaById(int id) async {
    final response = await dio.get(
      '${ApiEndpoints.camas}$id/',
    );

    final data = response.data;

    if (data is Map) {
      return Cama.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Respuesta inválida de la cama',
    );
  }
}

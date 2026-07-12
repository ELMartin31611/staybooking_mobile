import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/direccion_hotel.dart';
import '../../../domain/model/hotel.dart';

class HotelRemoteDatasource {
  HotelRemoteDatasource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<PaginatedHotels> getHoteles({
    int page = 1,
    String? search,
    String? estado,
    int? categoriaEstrellas,
    bool? permiteMascotas,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
        if (categoriaEstrellas != null)
          'categoria_estrellas': categoriaEstrellas,
        if (permiteMascotas != null) 'permite_mascotas': permiteMascotas,
      };

      final response = await _dio.get(
        ApiEndpoints.hoteles,
        queryParameters: queryParameters,
      );

      return PaginatedHotels.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioError(
        error,
      );
    }
  }

  Future<Hotel> getHotelById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hoteles}$id/',
      );

      return Hotel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioError(
        error,
      );
    }
  }

  Future<PaginatedDireccionesHotel> getDireccionesHotel({
    int? hotelId,
    String? provincia,
    String? ciudad,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (hotelId != null) 'hotel': hotelId,
        if (provincia != null && provincia.trim().isNotEmpty)
          'provincia': provincia.trim(),
        if (ciudad != null && ciudad.trim().isNotEmpty) 'ciudad': ciudad.trim(),
      };

      final response = await _dio.get(
        ApiEndpoints.direccionesHotel,
        queryParameters: queryParameters,
      );

      return PaginatedDireccionesHotel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioError(
        error,
      );
    }
  }
}

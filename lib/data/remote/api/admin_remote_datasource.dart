import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/habitacion.dart';
import '../../../domain/model/hotel.dart';
import '../../../domain/model/tipo_habitacion.dart';

class AdminRemoteDataSource {
  const AdminRemoteDataSource(this.dio);

  final Dio dio;

  Future<List<Hotel>> getHotels() async {
    final response = await dio.get(
      ApiEndpoints.hoteles,
      queryParameters: {
        'page_size': 100,
      },
    );

    return _parseList(
      response.data,
      Hotel.fromJson,
    );
  }

  Future<Hotel> createHotel(
    Map<String, dynamic> data, {
    required XFile logo,
  }) async {
    final response = await dio.post(
      ApiEndpoints.hoteles,
      data: await _hotelFormData(
        data,
        logo: logo,
      ),
    );

    return _parseObject(
      response.data,
      Hotel.fromJson,
    );
  }

  Future<Hotel> updateHotel(
    int hotelId,
    Map<String, dynamic> data, {
    XFile? logo,
  }) async {
    final response = await dio.patch(
      '${ApiEndpoints.hoteles}$hotelId/',
      data: await _hotelFormData(
        data,
        logo: logo,
      ),
    );

    return _parseObject(
      response.data,
      Hotel.fromJson,
    );
  }

  Future<void> deleteHotel(int hotelId) async {
    await dio.delete(
      '${ApiEndpoints.hoteles}$hotelId/',
    );
  }

  Future<List<Habitacion>> getRooms() async {
    final response = await dio.get(
      ApiEndpoints.habitaciones,
      queryParameters: {
        'page_size': 100,
      },
    );

    return _parseList(
      response.data,
      Habitacion.fromJson,
    );
  }

  Future<Habitacion> createRoom(
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post(
      ApiEndpoints.habitaciones,
      data: data,
    );

    return _parseObject(
      response.data,
      Habitacion.fromJson,
    );
  }

  Future<Habitacion> updateRoom(
    int roomId,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.patch(
      '${ApiEndpoints.habitaciones}$roomId/',
      data: data,
    );

    return _parseObject(
      response.data,
      Habitacion.fromJson,
    );
  }

  Future<void> deleteRoom(int roomId) async {
    await dio.delete(
      '${ApiEndpoints.habitaciones}$roomId/',
    );
  }

  Future<List<TipoHabitacion>> getRoomTypes() async {
    final response = await dio.get(
      ApiEndpoints.tiposHabitacion,
      queryParameters: {
        'page_size': 100,
      },
    );

    return _parseList(
      response.data,
      TipoHabitacion.fromJson,
    );
  }

  Future<TipoHabitacion> createRoomType(
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post(
      ApiEndpoints.tiposHabitacion,
      data: data,
    );

    return _parseObject(
      response.data,
      TipoHabitacion.fromJson,
    );
  }

  Future<TipoHabitacion> updateRoomType(
    int typeId,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.patch(
      '${ApiEndpoints.tiposHabitacion}$typeId/',
      data: data,
    );

    return _parseObject(
      response.data,
      TipoHabitacion.fromJson,
    );
  }

  Future<void> deleteRoomType(int typeId) async {
    await dio.delete(
      '${ApiEndpoints.tiposHabitacion}$typeId/',
    );
  }

  Future<FormData> _hotelFormData(
    Map<String, dynamic> data, {
    XFile? logo,
  }) async {
    final fields = <String, dynamic>{};

    data.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (key == 'sitio_web' &&
          value.toString().trim().isEmpty) {
        return;
      }

      fields[key] = value.toString();
    });

    if (logo != null) {
      final bytes = await logo.readAsBytes();

      fields['logo'] = MultipartFile.fromBytes(
        bytes,
        filename: logo.name,
      );
    }

    return FormData.fromMap(fields);
  }

  T _parseObject<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (responseData is Map) {
      return fromJson(
        Map<String, dynamic>.from(responseData),
      );
    }

    throw const FormatException(
      'La API no devolvió un objeto válido.',
    );
  }

  List<T> _parseList<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    dynamic rawItems = responseData;

    if (responseData is Map) {
      rawItems =
          responseData['results'] ??
          responseData['data'] ??
          const [];
    }

    if (rawItems is! List) {
      throw const FormatException(
        'La API no devolvió una lista válida.',
      );
    }

    return rawItems.map<T>((item) {
      if (item is! Map) {
        throw const FormatException(
          'La API devolvió un elemento inválido.',
        );
      }

      return fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}
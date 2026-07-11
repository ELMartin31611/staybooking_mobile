import 'package:dio/dio.dart';

import '../../../domain/models/servicio.dart';

abstract class ServicioRemoteDataSource {
  Future<ServicioPage> obtenerServicios({
    String? buscar,
    bool? activo,
  });

  Future<Servicio> obtenerServicio(
    int servicioId,
  );
}

class ServicioRemoteDataSourceImpl implements ServicioRemoteDataSource {
  final Dio dio;

  static const String _serviciosEndpoint = 'servicios/';

  const ServicioRemoteDataSourceImpl(
    this.dio,
  );

  @override
  Future<ServicioPage> obtenerServicios({
    String? buscar,
    bool? activo,
  }) async {
    final response = await dio.get(
      _serviciosEndpoint,
      queryParameters: {
        if (buscar != null && buscar.trim().isNotEmpty) 'search': buscar.trim(),
        if (activo != null) 'activo': activo,
      },
    );

    return ServicioPage.fromJson(
      response.data,
    );
  }

  @override
  Future<Servicio> obtenerServicio(
    int servicioId,
  ) async {
    final response = await dio.get(
      '$_serviciosEndpoint$servicioId/',
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException(
        'La respuesta del servicio no tiene un formato válido.',
      );
    }

    return Servicio.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}

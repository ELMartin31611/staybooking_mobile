import 'package:dio/dio.dart';

import '../../../domain/models/tipo_habitacion_servicio.dart';

abstract class TipoHabitacionServicioRemoteDataSource {
  Future<TipoHabitacionServicioPage> obtenerServiciosPorTipoHabitacion(
    int tipoHabitacionId,
  );
}

class TipoHabitacionServicioRemoteDataSourceImpl
    implements TipoHabitacionServicioRemoteDataSource {
  final Dio dio;

  static const String _endpoint = 'tipos-habitacion-servicios/';

  const TipoHabitacionServicioRemoteDataSourceImpl(
    this.dio,
  );

  @override
  Future<TipoHabitacionServicioPage> obtenerServiciosPorTipoHabitacion(
    int tipoHabitacionId,
  ) async {
    final response = await dio.get(
      _endpoint,
      queryParameters: {
        'tipo_habitacion': tipoHabitacionId,
      },
    );

    final page = TipoHabitacionServicioPage.fromJson(
      response.data,
    );

    final relaciones = page.results
        .where(
          (relacion) =>
              relacion.tipoHabitacionId == null ||
              relacion.tipoHabitacionId == tipoHabitacionId,
        )
        .toList();

    return TipoHabitacionServicioPage(
      count: relaciones.length,
      next: page.next,
      previous: page.previous,
      results: relaciones,
    );
  }
}

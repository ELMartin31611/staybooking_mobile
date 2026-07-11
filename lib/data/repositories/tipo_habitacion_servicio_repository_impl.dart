import '../../domain/models/tipo_habitacion_servicio.dart';
import '../../domain/repositories/tipo_habitacion_servicio_repository.dart';
import '../datasources/remote/tipo_habitacion_servicio_remote_datasource.dart';

class TipoHabitacionServicioRepositoryImpl
    implements TipoHabitacionServicioRepository {
  final TipoHabitacionServicioRemoteDataSource
      remoteDataSource;

  const TipoHabitacionServicioRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<TipoHabitacionServicioPage>
      obtenerServiciosPorTipoHabitacion(
    int tipoHabitacionId,
  ) {
    return remoteDataSource
        .obtenerServiciosPorTipoHabitacion(
      tipoHabitacionId,
    );
  }
}
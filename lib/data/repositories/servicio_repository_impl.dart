import '../../domain/models/servicio.dart';
import '../../domain/repositories/servicio_repository.dart';
import '../datasources/remote/servicio_remote_datasource.dart';

class ServicioRepositoryImpl implements ServicioRepository {
  final ServicioRemoteDataSource remoteDataSource;

  const ServicioRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<ServicioPage> obtenerServicios({
    String? buscar,
    bool? activo,
  }) {
    return remoteDataSource.obtenerServicios(
      buscar: buscar,
      activo: activo,
    );
  }

  @override
  Future<Servicio> obtenerServicio(
    int servicioId,
  ) {
    return remoteDataSource.obtenerServicio(
      servicioId,
    );
  }
}

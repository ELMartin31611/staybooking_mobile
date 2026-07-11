import '../../domain/model/tipo_habitacion.dart';
import '../../domain/repository/tipo_habitacion_repository.dart';
import '../remote/api/tipo_habitacion_remote_datasource.dart';

class TipoHabitacionRepositoryImpl implements TipoHabitacionRepository {
  final TipoHabitacionRemoteDatasource remoteDatasource;

  const TipoHabitacionRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<PaginatedTiposHabitacion> getTiposHabitacion({
    int page = 1,
    int? hotelId,
    String? search,
  }) {
    return remoteDatasource.getTiposHabitacion(
      page: page,
      hotelId: hotelId,
      search: search,
    );
  }

  @override
  Future<TipoHabitacion> getTipoHabitacionById(
    int id,
  ) {
    return remoteDatasource.getTipoHabitacionById(id);
  }
}

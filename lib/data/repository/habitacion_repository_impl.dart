import '../../domain/model/habitacion.dart';
import '../../domain/repository/habitacion_repository.dart';
import '../remote/api/habitacion_remote_datasource.dart';

class HabitacionRepositoryImpl implements HabitacionRepository {
  final HabitacionRemoteDatasource remoteDatasource;

  const HabitacionRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<PaginatedHabitaciones> getHabitaciones({
    int page = 1,
    int? hotelId,
    int? tipoHabitacionId,
    String? estado,
    bool? disponible,
    String? search,
  }) {
    return remoteDatasource.getHabitaciones(
      page: page,
      hotelId: hotelId,
      tipoHabitacionId: tipoHabitacionId,
      estado: estado,
      disponible: disponible,
      search: search,
    );
  }

  @override
  Future<Habitacion> getHabitacionById(int id) {
    return remoteDatasource.getHabitacionById(id);
  }
}

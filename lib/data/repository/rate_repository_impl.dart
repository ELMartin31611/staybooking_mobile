import '../../domain/model/tarifa_habitacion.dart';
import '../../domain/model/temporada.dart';
import '../../domain/repository/rate_repository.dart';
import '../remote/api/rate_remote_datasource.dart';

class RateRepositoryImpl implements RateRepository {
  const RateRepositoryImpl(this._remoteDataSource);

  final RateRemoteDataSource _remoteDataSource;

  @override
  Future<List<Temporada>> getTemporadas({
    bool? isActive,
    String? search,
  }) {
    return _remoteDataSource.getTemporadas(
      isActive: isActive,
      search: search,
    );
  }

  @override
  Future<Temporada> getTemporadaById(int id) {
    return _remoteDataSource.getTemporadaById(id);
  }

  @override
  Future<List<TarifaHabitacion>> getTarifasHabitacion({
    int? tipoHabitacionId,
    int? temporadaId,
    bool? isActive,
    String? moneda,
  }) {
    return _remoteDataSource.getTarifasHabitacion(
      tipoHabitacionId: tipoHabitacionId,
      temporadaId: temporadaId,
      isActive: isActive,
      moneda: moneda,
    );
  }

  @override
  Future<TarifaHabitacion> getTarifaHabitacionById(int id) {
    return _remoteDataSource.getTarifaHabitacionById(id);
  }
}

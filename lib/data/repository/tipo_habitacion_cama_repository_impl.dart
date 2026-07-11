import '../../domain/model/tipo_habitacion_cama.dart';
import '../../domain/repository/tipo_habitacion_cama_repository.dart';
import '../remote/api/tipo_habitacion_cama_remote_datasource.dart';

class TipoHabitacionCamaRepositoryImpl implements TipoHabitacionCamaRepository {
  final TipoHabitacionCamaRemoteDatasource remoteDatasource;

  const TipoHabitacionCamaRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<PaginatedTiposHabitacionCama> getTiposHabitacionCama({
    int page = 1,
    int? tipoHabitacionId,
    int? camaId,
  }) {
    return remoteDatasource.getTiposHabitacionCama(
      page: page,
      tipoHabitacionId: tipoHabitacionId,
      camaId: camaId,
    );
  }

  @override
  Future<TipoHabitacionCama> getTipoHabitacionCamaById(int id) {
    return remoteDatasource.getTipoHabitacionCamaById(id);
  }
}

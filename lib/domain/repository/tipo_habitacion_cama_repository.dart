import '../model/tipo_habitacion_cama.dart';

abstract class TipoHabitacionCamaRepository {
  Future<PaginatedTiposHabitacionCama> getTiposHabitacionCama({
    int page = 1,
    int? tipoHabitacionId,
    int? camaId,
  });

  Future<TipoHabitacionCama> getTipoHabitacionCamaById(int id);
}

import '../model/tipo_habitacion.dart';

abstract class TipoHabitacionRepository {
  Future<PaginatedTiposHabitacion> getTiposHabitacion({
    int page = 1,
    int? hotelId,
    String? search,
  });

  Future<TipoHabitacion> getTipoHabitacionById(int id);
}

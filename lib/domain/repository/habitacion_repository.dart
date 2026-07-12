import '../model/habitacion.dart';

abstract class HabitacionRepository {
  Future<PaginatedHabitaciones> getHabitaciones({
    int page = 1,
    int? hotelId,
    int? tipoHabitacionId,
    String? estado,
    bool? disponible,
    String? search,
  });

  Future<Habitacion> getHabitacionById(int id);
}

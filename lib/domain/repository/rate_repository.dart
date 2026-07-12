import '../model/tarifa_habitacion.dart';
import '../model/temporada.dart';

abstract class RateRepository {
  Future<List<Temporada>> getTemporadas({
    bool? isActive,
    String? search,
  });

  Future<Temporada> getTemporadaById(int id);

  Future<List<TarifaHabitacion>> getTarifasHabitacion({
    int? tipoHabitacionId,
    int? temporadaId,
    bool? isActive,
    String? moneda,
  });

  Future<TarifaHabitacion> getTarifaHabitacionById(int id);
}

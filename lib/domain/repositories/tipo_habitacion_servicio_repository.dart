import '../models/tipo_habitacion_servicio.dart';

abstract class TipoHabitacionServicioRepository {
  Future<TipoHabitacionServicioPage>
      obtenerServiciosPorTipoHabitacion(
    int tipoHabitacionId,
  );
}
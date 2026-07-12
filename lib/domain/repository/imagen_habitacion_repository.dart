import '../model/imagen_habitacion.dart';

abstract class ImagenHabitacionRepository {
  Future<PaginatedImagenesHabitacion> getImagenesHabitacion({
    int page = 1,
    int? habitacionId,
  });

  Future<ImagenHabitacion> getImagenHabitacionById(int id);
}

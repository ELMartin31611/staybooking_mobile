import '../../domain/model/imagen_habitacion.dart';
import '../../domain/repository/imagen_habitacion_repository.dart';
import '../remote/api/imagen_habitacion_remote_datasource.dart';

class ImagenHabitacionRepositoryImpl implements ImagenHabitacionRepository {
  final ImagenHabitacionRemoteDatasource remoteDatasource;

  const ImagenHabitacionRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<PaginatedImagenesHabitacion> getImagenesHabitacion({
    int page = 1,
    int? habitacionId,
  }) {
    return remoteDatasource.getImagenesHabitacion(
      page: page,
      habitacionId: habitacionId,
    );
  }

  @override
  Future<ImagenHabitacion> getImagenHabitacionById(int id) {
    return remoteDatasource.getImagenHabitacionById(id);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/imagen_habitacion_remote_datasource.dart';
import '../../data/repository/imagen_habitacion_repository_impl.dart';
import '../../domain/model/imagen_habitacion.dart';
import '../../domain/repository/imagen_habitacion_repository.dart';
import 'auth_provider.dart';

final imagenHabitacionRemoteDatasourceProvider =
    Provider<ImagenHabitacionRemoteDatasource>((ref) {
  return ImagenHabitacionRemoteDatasource(
    dio: ref.watch(authDioProvider),
  );
});

final imagenHabitacionRepositoryProvider =
    Provider<ImagenHabitacionRepository>((ref) {
  return ImagenHabitacionRepositoryImpl(
    remoteDatasource: ref.watch(
      imagenHabitacionRemoteDatasourceProvider,
    ),
  );
});

final imagenesHabitacionProvider =
    FutureProvider.autoDispose<PaginatedImagenesHabitacion>((ref) {
  return ref.watch(imagenHabitacionRepositoryProvider).getImagenesHabitacion();
});

final imagenesPorHabitacionProvider = FutureProvider.autoDispose
    .family<PaginatedImagenesHabitacion, int>((ref, habitacionId) {
  return ref.watch(imagenHabitacionRepositoryProvider).getImagenesHabitacion(
        habitacionId: habitacionId,
      );
});

final imagenHabitacionDetalleProvider =
    FutureProvider.autoDispose.family<ImagenHabitacion, int>((ref, id) {
  return ref
      .watch(imagenHabitacionRepositoryProvider)
      .getImagenHabitacionById(id);
});

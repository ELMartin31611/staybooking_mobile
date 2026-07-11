import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/habitacion_remote_datasource.dart';
import '../../data/repository/habitacion_repository_impl.dart';
import '../../domain/model/habitacion.dart';
import '../../domain/repository/habitacion_repository.dart';
import 'auth_provider.dart';

final habitacionRemoteDatasourceProvider =
    Provider<HabitacionRemoteDatasource>((ref) {
  return HabitacionRemoteDatasource(
    dio: ref.watch(authDioProvider),
  );
});

final habitacionRepositoryProvider = Provider<HabitacionRepository>((ref) {
  return HabitacionRepositoryImpl(
    remoteDatasource: ref.watch(
      habitacionRemoteDatasourceProvider,
    ),
  );
});

final habitacionesProvider =
    FutureProvider.autoDispose<PaginatedHabitaciones>((ref) {
  return ref.watch(habitacionRepositoryProvider).getHabitaciones();
});

final habitacionesPorHotelProvider = FutureProvider.autoDispose
    .family<PaginatedHabitaciones, int>((ref, hotelId) {
  return ref.watch(habitacionRepositoryProvider).getHabitaciones(
        hotelId: hotelId,
      );
});

final habitacionesPorTipoProvider = FutureProvider.autoDispose
    .family<PaginatedHabitaciones, int>((ref, tipoHabitacionId) {
  return ref.watch(habitacionRepositoryProvider).getHabitaciones(
        tipoHabitacionId: tipoHabitacionId,
      );
});

final habitacionDetalleProvider =
    FutureProvider.autoDispose.family<Habitacion, int>((ref, id) {
  return ref.watch(habitacionRepositoryProvider).getHabitacionById(id);
});

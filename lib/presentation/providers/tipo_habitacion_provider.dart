import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/tipo_habitacion_remote_datasource.dart';
import '../../data/repository/tipo_habitacion_repository_impl.dart';
import '../../domain/model/tipo_habitacion.dart';
import '../../domain/repository/tipo_habitacion_repository.dart';
import 'auth_provider.dart';

final tipoHabitacionRemoteDatasourceProvider =
    Provider<TipoHabitacionRemoteDatasource>((ref) {
  return TipoHabitacionRemoteDatasource(
    dio: ref.watch(authDioProvider),
  );
});

final tipoHabitacionRepositoryProvider =
    Provider<TipoHabitacionRepository>((ref) {
  return TipoHabitacionRepositoryImpl(
    remoteDatasource: ref.watch(
      tipoHabitacionRemoteDatasourceProvider,
    ),
  );
});

final tiposHabitacionProvider =
    FutureProvider.autoDispose<PaginatedTiposHabitacion>(
  (ref) {
    return ref.watch(tipoHabitacionRepositoryProvider).getTiposHabitacion();
  },
);

final tiposHabitacionPorHotelProvider =
    FutureProvider.autoDispose.family<PaginatedTiposHabitacion, int>(
  (ref, hotelId) {
    return ref.watch(tipoHabitacionRepositoryProvider).getTiposHabitacion(
          hotelId: hotelId,
        );
  },
);

final tipoHabitacionDetalleProvider =
    FutureProvider.autoDispose.family<TipoHabitacion, int>(
  (ref, id) {
    return ref
        .watch(tipoHabitacionRepositoryProvider)
        .getTipoHabitacionById(id);
  },
);

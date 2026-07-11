import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/tipo_habitacion_cama_remote_datasource.dart';
import '../../data/repository/tipo_habitacion_cama_repository_impl.dart';
import '../../domain/model/tipo_habitacion_cama.dart';
import '../../domain/repository/tipo_habitacion_cama_repository.dart';
import 'auth_provider.dart';

final tipoHabitacionCamaRemoteDatasourceProvider =
    Provider<TipoHabitacionCamaRemoteDatasource>((ref) {
  return TipoHabitacionCamaRemoteDatasource(
    dio: ref.watch(authDioProvider),
  );
});

final tipoHabitacionCamaRepositoryProvider =
    Provider<TipoHabitacionCamaRepository>((ref) {
  return TipoHabitacionCamaRepositoryImpl(
    remoteDatasource: ref.watch(
      tipoHabitacionCamaRemoteDatasourceProvider,
    ),
  );
});

final tiposHabitacionCamaProvider =
    FutureProvider.autoDispose<PaginatedTiposHabitacionCama>((ref) {
  return ref
      .watch(tipoHabitacionCamaRepositoryProvider)
      .getTiposHabitacionCama();
});

final camasPorTipoHabitacionProvider =
    FutureProvider.autoDispose.family<PaginatedTiposHabitacionCama, int>(
  (ref, tipoHabitacionId) {
    return ref
        .watch(tipoHabitacionCamaRepositoryProvider)
        .getTiposHabitacionCama(
          tipoHabitacionId: tipoHabitacionId,
        );
  },
);

final tipoHabitacionCamaDetalleProvider =
    FutureProvider.autoDispose.family<TipoHabitacionCama, int>(
  (ref, id) {
    return ref
        .watch(tipoHabitacionCamaRepositoryProvider)
        .getTipoHabitacionCamaById(id);
  },
);

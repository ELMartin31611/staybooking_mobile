import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/tipo_habitacion_servicio_remote_datasource.dart';
import '../../data/repositories/tipo_habitacion_servicio_repository_impl.dart';
import '../../domain/models/tipo_habitacion_servicio.dart';
import '../../domain/repositories/tipo_habitacion_servicio_repository.dart';
import 'auth_provider.dart';

final tipoHabitacionServicioRemoteDataSourceProvider =
    Provider<TipoHabitacionServicioRemoteDataSource>(
  (ref) {
    final dio = ref.watch(
      authDioProvider,
    );

    return TipoHabitacionServicioRemoteDataSourceImpl(
      dio,
    );
  },
);

final tipoHabitacionServicioRepositoryProvider =
    Provider<TipoHabitacionServicioRepository>(
  (ref) {
    final remoteDataSource = ref.watch(
      tipoHabitacionServicioRemoteDataSourceProvider,
    );

    return TipoHabitacionServicioRepositoryImpl(
      remoteDataSource,
    );
  },
);

final serviciosPorTipoHabitacionProvider =
    FutureProvider.autoDispose.family<TipoHabitacionServicioPage, int>(
  (ref, tipoHabitacionId) {
    final repository = ref.watch(
      tipoHabitacionServicioRepositoryProvider,
    );

    return repository.obtenerServiciosPorTipoHabitacion(
      tipoHabitacionId,
    );
  },
);

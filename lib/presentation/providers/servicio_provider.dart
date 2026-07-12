import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/servicio_remote_datasource.dart';
import '../../data/repositories/servicio_repository_impl.dart';
import '../../domain/models/servicio.dart';
import '../../domain/repositories/servicio_repository.dart';
import 'auth_provider.dart';

final servicioRemoteDataSourceProvider =
    Provider<ServicioRemoteDataSource>((ref) {
  final dio = ref.watch(
    authDioProvider,
  );

  return ServicioRemoteDataSourceImpl(
    dio,
  );
});

final servicioRepositoryProvider = Provider<ServicioRepository>((ref) {
  final remoteDataSource = ref.watch(
    servicioRemoteDataSourceProvider,
  );

  return ServicioRepositoryImpl(
    remoteDataSource,
  );
});

final serviciosProvider = FutureProvider.autoDispose<ServicioPage>((ref) {
  final repository = ref.watch(
    servicioRepositoryProvider,
  );

  return repository.obtenerServicios(
    activo: true,
  );
});

final servicioDetalleProvider =
    FutureProvider.autoDispose.family<Servicio, int>((ref, servicioId) {
  final repository = ref.watch(
    servicioRepositoryProvider,
  );

  return repository.obtenerServicio(
    servicioId,
  );
});

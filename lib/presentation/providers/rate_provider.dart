import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/dio_client.dart';
import '../../data/remote/api/rate_remote_datasource.dart';
import '../../data/repository/rate_repository_impl.dart';
import '../../domain/model/tarifa_habitacion.dart';
import '../../domain/model/temporada.dart';
import '../../domain/repository/rate_repository.dart';

final rateRemoteDataSourceProvider = Provider<RateRemoteDataSource>((ref) {
  return RateRemoteDataSource(DioClient.dio);
});

final rateRepositoryProvider = Provider<RateRepository>((ref) {
  final remoteDataSource = ref.watch(rateRemoteDataSourceProvider);

  return RateRepositoryImpl(remoteDataSource);
});

final temporadasProvider = FutureProvider.autoDispose<List<Temporada>>((ref) {
  final repository = ref.watch(rateRepositoryProvider);

  return repository.getTemporadas(
    isActive: true,
  );
});

final temporadaDetailProvider =
    FutureProvider.autoDispose.family<Temporada, int>((ref, id) {
  final repository = ref.watch(rateRepositoryProvider);

  return repository.getTemporadaById(id);
});

final tarifasHabitacionProvider =
    FutureProvider.autoDispose<List<TarifaHabitacion>>((ref) {
  final repository = ref.watch(rateRepositoryProvider);

  return repository.getTarifasHabitacion(
    isActive: true,
  );
});

final tarifaHabitacionDetailProvider =
    FutureProvider.autoDispose.family<TarifaHabitacion, int>((ref, id) {
  final repository = ref.watch(rateRepositoryProvider);

  return repository.getTarifaHabitacionById(id);
});

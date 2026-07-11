import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/cama_remote_datasource.dart';
import '../../data/repository/cama_repository_impl.dart';
import '../../domain/model/cama.dart';
import '../../domain/repository/cama_repository.dart';
import 'auth_provider.dart';

final camaRemoteDatasourceProvider = Provider<CamaRemoteDatasource>((ref) {
  return CamaRemoteDatasource(
    dio: ref.watch(authDioProvider),
  );
});

final camaRepositoryProvider = Provider<CamaRepository>((ref) {
  return CamaRepositoryImpl(
    remoteDatasource: ref.watch(
      camaRemoteDatasourceProvider,
    ),
  );
});

final camasProvider = FutureProvider.autoDispose<PaginatedCamas>((ref) {
  return ref.watch(camaRepositoryProvider).getCamas();
});

final camaDetalleProvider =
    FutureProvider.autoDispose.family<Cama, int>((ref, id) {
  return ref.watch(camaRepositoryProvider).getCamaById(id);
});

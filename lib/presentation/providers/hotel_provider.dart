import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../../data/remote/api/hotel_remote_datasource.dart';
import '../../data/repository/hotel_repository_impl.dart';
import '../../domain/model/direccion_hotel.dart';
import '../../domain/model/hotel.dart';
import '../../domain/repository/hotel_repository.dart';

final hotelRemoteDatasourceProvider = Provider<HotelRemoteDatasource>((ref) {
  final dio = ref.watch(authDioProvider);

  return HotelRemoteDatasource(
    dio: dio,
  );
});

final hotelRepositoryProvider = Provider<HotelRepository>((ref) {
  final remoteDatasource = ref.watch(
    hotelRemoteDatasourceProvider,
  );

  return HotelRepositoryImpl(
    remoteDatasource,
  );
});

final hotelesProvider = FutureProvider.autoDispose<PaginatedHotels>((ref) {
  final repository = ref.watch(
    hotelRepositoryProvider,
  );

  return repository.getHoteles();
});

final hotelDetalleProvider =
    FutureProvider.autoDispose.family<Hotel, int>((ref, id) {
  final repository = ref.watch(
    hotelRepositoryProvider,
  );

  return repository.getHotelById(id);
});

final direccionesHotelProvider = FutureProvider.autoDispose
    .family<PaginatedDireccionesHotel, int?>((ref, hotelId) {
  final repository = ref.watch(
    hotelRepositoryProvider,
  );

  return repository.getDireccionesHotel(
    hotelId: hotelId,
  );
});

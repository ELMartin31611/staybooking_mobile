import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/dio_client.dart';
import '../../data/remote/api/reservation_remote_datasource.dart';
import '../../data/repository/reservation_repository_impl.dart';
import '../../domain/model/huesped_reserva.dart';
import '../../domain/model/reserva.dart';
import '../../domain/model/reserva_habitacion.dart';
import '../../domain/repository/reservation_repository.dart';

final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
  return ReservationRemoteDataSource(DioClient.dio);
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final remoteDataSource = ref.watch(
    reservationRemoteDataSourceProvider,
  );

  return ReservationRepositoryImpl(remoteDataSource);
});

final reservasProvider = FutureProvider.autoDispose<List<Reserva>>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);

  return repository.getReservas();
});

final reservaDetailProvider =
    FutureProvider.autoDispose.family<Reserva, int>((ref, id) {
  final repository = ref.watch(reservationRepositoryProvider);

  return repository.getReservaById(id);
});

final reservaHabitacionesProvider =
    FutureProvider.autoDispose.family<List<ReservaHabitacion>, int>(
  (ref, reservaId) {
    final repository = ref.watch(reservationRepositoryProvider);

    return repository.getReservaHabitaciones(
      reservaId: reservaId,
    );
  },
);

final huespedesReservaProvider =
    FutureProvider.autoDispose.family<List<HuespedReserva>, int>(
  (ref, reservaId) {
    final repository = ref.watch(reservationRepositoryProvider);

    return repository.getHuespedesReserva(
      reservaId: reservaId,
    );
  },
);

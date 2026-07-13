import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/reservation_remote_datasource.dart';
import '../../data/repository/reservation_repository_impl.dart';
import '../../domain/model/cliente.dart';
import '../../domain/model/habitacion.dart';
import '../../domain/model/huesped_reserva.dart';
import '../../domain/model/reserva.dart';
import '../../domain/model/reserva_habitacion.dart';
import '../../domain/repository/reservation_repository.dart';
import 'auth_provider.dart';
import 'habitacion_provider.dart';
import 'reservation_cart_provider.dart';

final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
  return ReservationRemoteDataSource(
    ref.watch(authDioProvider),
  );
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final remoteDataSource = ref.watch(
    reservationRemoteDataSourceProvider,
  );

  return ReservationRepositoryImpl(remoteDataSource);
});

final currentClienteProvider =
    FutureProvider.autoDispose<Cliente?>((ref) async {
  final profile = ref.watch(
    authControllerProvider.select(
      (state) => state.profile,
    ),
  );

  if (profile == null) {
    return null;
  }

  final repository = ref.watch(authRepositoryProvider);

  return repository.getClienteByPerfil(profile.id);
});

final selectedReservationRoomsProvider =
    FutureProvider.autoDispose<List<Habitacion>>((ref) async {
  final roomIds = ref.watch(
    reservationCartProvider.select(
      (state) => state.roomIds,
    ),
  );

  if (roomIds.isEmpty) {
    return const <Habitacion>[];
  }

  final repository = ref.watch(habitacionRepositoryProvider);

  return Future.wait(
    roomIds.map(repository.getHabitacionById),
  );
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

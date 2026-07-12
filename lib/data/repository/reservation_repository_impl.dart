import '../../domain/model/huesped_reserva.dart';
import '../../domain/model/reserva.dart';
import '../../domain/model/reserva_habitacion.dart';
import '../../domain/repository/reservation_repository.dart';
import '../remote/api/reservation_remote_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  const ReservationRepositoryImpl(this._remoteDataSource);

  final ReservationRemoteDataSource _remoteDataSource;

  @override
  Future<List<Reserva>> getReservas({
    ReservaEstado? estado,
    int? clienteId,
    String? search,
  }) {
    return _remoteDataSource.getReservas(
      estado: estado,
      clienteId: clienteId,
      search: search,
    );
  }

  @override
  Future<Reserva> getReservaById(int id) {
    return _remoteDataSource.getReservaById(id);
  }

  @override
  Future<Reserva> createReserva(ReservaRequest request) {
    return _remoteDataSource.createReserva(request);
  }

  @override
  Future<Reserva> updateReserva(int id, ReservaRequest request) {
    return _remoteDataSource.updateReserva(id, request);
  }

  @override
  Future<Reserva> updateReservaEstado(
    int id,
    ReservaEstado estado,
  ) {
    return _remoteDataSource.updateReservaEstado(id, estado);
  }

  @override
  Future<void> deleteReserva(int id) {
    return _remoteDataSource.deleteReserva(id);
  }

  @override
  Future<List<ReservaHabitacion>> getReservaHabitaciones({
    required int reservaId,
  }) {
    return _remoteDataSource.getReservaHabitaciones(
      reservaId: reservaId,
    );
  }

  @override
  Future<ReservaHabitacion> createReservaHabitacion(
    ReservaHabitacionRequest request,
  ) {
    return _remoteDataSource.createReservaHabitacion(request);
  }

  @override
  Future<void> deleteReservaHabitacion(int id) {
    return _remoteDataSource.deleteReservaHabitacion(id);
  }

  @override
  Future<List<HuespedReserva>> getHuespedesReserva({
    required int reservaId,
  }) {
    return _remoteDataSource.getHuespedesReserva(
      reservaId: reservaId,
    );
  }

  @override
  Future<HuespedReserva> createHuespedReserva(
    HuespedReservaRequest request,
  ) {
    return _remoteDataSource.createHuespedReserva(request);
  }

  @override
  Future<HuespedReserva> updateHuespedReserva(
    int id,
    HuespedReservaRequest request,
  ) {
    return _remoteDataSource.updateHuespedReserva(
      id,
      request,
    );
  }

  @override
  Future<void> deleteHuespedReserva(int id) {
    return _remoteDataSource.deleteHuespedReserva(id);
  }
}

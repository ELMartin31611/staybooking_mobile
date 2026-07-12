import '../model/huesped_reserva.dart';
import '../model/reserva.dart';
import '../model/reserva_habitacion.dart';

abstract class ReservationRepository {
  Future<List<Reserva>> getReservas({
    ReservaEstado? estado,
    int? clienteId,
    String? search,
  });

  Future<Reserva> getReservaById(int id);

  Future<Reserva> createReserva(ReservaRequest request);

  Future<Reserva> updateReserva(int id, ReservaRequest request);

  Future<Reserva> updateReservaEstado(int id, ReservaEstado estado);

  Future<void> deleteReserva(int id);

  Future<List<ReservaHabitacion>> getReservaHabitaciones({
    required int reservaId,
  });

  Future<ReservaHabitacion> createReservaHabitacion(
    ReservaHabitacionRequest request,
  );

  Future<void> deleteReservaHabitacion(int id);

  Future<List<HuespedReserva>> getHuespedesReserva({
    required int reservaId,
  });

  Future<HuespedReserva> createHuespedReserva(
    HuespedReservaRequest request,
  );

  Future<HuespedReserva> updateHuespedReserva(
    int id,
    HuespedReservaRequest request,
  );

  Future<void> deleteHuespedReserva(int id);
}

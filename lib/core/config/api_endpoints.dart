class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = 'register/';
  static const String login = 'login/';
  static const String refresh = 'token/refresh/';
  static const String profile = 'perfil/';

  // Usuario / cliente
  static const String perfiles = 'perfiles/';
  static const String clientes = 'clientes/';
  static const String direccionesCliente = 'direcciones/';
  static const String documentosCliente = 'documentos/';

  // Admin / empleados
  static const String cargos = 'cargos/';
  static const String turnos = 'turnos/';
  static const String empleados = 'empleados/';
  static const String empleadoTurnos = 'empleado-turnos/';

  // Hoteles
  static const String hoteles = 'hoteles/';
  static const String direccionesHotel = 'direcciones-hotel/';

  // Habitaciones
  static const String tiposHabitacion = 'tipos-habitacion/';
  static const String habitaciones = 'habitaciones/';
  static const String camas = 'camas/';
  static const String tiposHabitacionCamas = 'tipos-habitacion-camas/';
  static const String imagenesHabitacion = 'imagenes-habitacion/';

  // Servicios
  static const String servicios = 'servicios/';
  static const String tiposHabitacionServicios = 'tipos-habitacion-servicios/';

  // Tarifas
  static const String temporadas = 'temporadas/';
  static const String tarifasHabitacion = 'tarifas-habitacion/';

  // Reservas
  static const String reservas = 'reservas/';
  static const String reservaHabitaciones = 'reserva-habitaciones/';
  static const String huespedesReserva = 'huespedes-reserva/';

  // Pagos / facturas
  static const String pagos = 'pagos/';
  static const String facturas = 'facturas/';

  // Notificaciones
  static const String notificacionesSistema = 'notificaciones-sistema/';
}

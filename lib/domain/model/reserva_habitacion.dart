enum ReservaHabitacionEstado {
  activa,
  cancelada,
  finalizada;

  String get apiValue => name;

  static ReservaHabitacionEstado fromApi(String value) {
    return ReservaHabitacionEstado.values.firstWhere(
      (estado) => estado.apiValue == value,
      orElse: () => throw FormatException(
        'Estado de habitación reservada desconocido: $value',
      ),
    );
  }
}

class ReservaHabitacion {
  const ReservaHabitacion({
    required this.id,
    required this.reservaId,
    required this.habitacionId,
    required this.habitacionNumero,
    required this.tipoHabitacion,
    required this.tarifaId,
    required this.precioNoche,
    required this.noches,
    required this.subtotal,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int reservaId;
  final int habitacionId;
  final String habitacionNumero;
  final String tipoHabitacion;
  final int tarifaId;
  final double precioNoche;
  final int noches;
  final double subtotal;
  final ReservaHabitacionEstado estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReservaHabitacion.fromJson(Map<String, dynamic> json) {
    return ReservaHabitacion(
      id: json['id'] as int,
      reservaId: json['reserva'] as int,
      habitacionId: json['habitacion'] as int,
      habitacionNumero: json['habitacion_numero'] as String,
      tipoHabitacion: json['tipo_habitacion'] as String,
      tarifaId: json['tarifa'] as int,
      precioNoche: double.parse(json['precio_noche'].toString()),
      noches: json['noches'] as int,
      subtotal: double.parse(json['subtotal'].toString()),
      estado: ReservaHabitacionEstado.fromApi(json['estado'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ReservaHabitacionRequest {
  const ReservaHabitacionRequest({
    required this.reservaId,
    required this.habitacionId,
    required this.tarifaId,
    this.estado = ReservaHabitacionEstado.activa,
  });

  final int reservaId;
  final int habitacionId;
  final int tarifaId;
  final ReservaHabitacionEstado estado;

  Map<String, dynamic> toJson() {
    return {
      'reserva': reservaId,
      'habitacion': habitacionId,
      'tarifa': tarifaId,
      'estado': estado.apiValue,
    };
  }
}

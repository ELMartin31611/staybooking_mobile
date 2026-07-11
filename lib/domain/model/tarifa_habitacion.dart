class TarifaHabitacion {
  const TarifaHabitacion({
    required this.id,
    required this.tipoHabitacionId,
    required this.tipoHabitacionNombre,
    required this.temporadaId,
    required this.temporadaNombre,
    required this.precioNoche,
    required this.precioFinSemana,
    required this.precioPersonaExtra,
    required this.moneda,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int tipoHabitacionId;
  final String tipoHabitacionNombre;
  final int temporadaId;
  final String temporadaNombre;
  final double precioNoche;
  final double? precioFinSemana;
  final double precioPersonaExtra;
  final String moneda;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TarifaHabitacion.fromJson(Map<String, dynamic> json) {
    final precioFinSemana = json['precio_fin_semana'];

    return TarifaHabitacion(
      id: json['id'] as int,
      tipoHabitacionId: json['tipo_habitacion'] as int,
      tipoHabitacionNombre: json['tipo_habitacion_nombre'] as String,
      temporadaId: json['temporada'] as int,
      temporadaNombre: json['temporada_nombre'] as String,
      precioNoche: double.parse(json['precio_noche'].toString()),
      precioFinSemana: precioFinSemana == null
          ? null
          : double.parse(precioFinSemana.toString()),
      precioPersonaExtra: double.parse(
        json['precio_persona_extra'].toString(),
      ),
      moneda: json['moneda'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

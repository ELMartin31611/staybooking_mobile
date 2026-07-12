class Temporada {
  const Temporada({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.porcentajeIncremento,
    required this.descripcion,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double porcentajeIncremento;
  final String? descripcion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Temporada.fromJson(Map<String, dynamic> json) {
    return Temporada(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      porcentajeIncremento: double.parse(
        json['porcentaje_incremento'].toString(),
      ),
      descripcion: json['descripcion']?.toString(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class HuespedReserva {
  const HuespedReserva({
    required this.id,
    required this.reservaId,
    required this.reservaCodigo,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.edad,
    required this.telefono,
    required this.esTitular,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int reservaId;
  final String reservaCodigo;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final int? edad;
  final String? telefono;
  final bool esTitular;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get nombreCompleto => '$nombres $apellidos';

  factory HuespedReserva.fromJson(Map<String, dynamic> json) {
    return HuespedReserva(
      id: json['id'] as int,
      reservaId: json['reserva'] as int,
      reservaCodigo: json['reserva_codigo'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      tipoDocumento: json['tipo_documento'] as String,
      numeroDocumento: json['numero_documento'] as String,
      edad: json['edad'] as int?,
      telefono: json['telefono']?.toString(),
      esTitular: json['es_titular'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class HuespedReservaRequest {
  const HuespedReservaRequest({
    required this.reservaId,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.esTitular,
    this.edad,
    this.telefono,
  });

  final int reservaId;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final int? edad;
  final String? telefono;
  final bool esTitular;

  Map<String, dynamic> toJson() {
    return {
      'reserva': reservaId,
      'nombres': nombres.trim(),
      'apellidos': apellidos.trim(),
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento.trim(),
      'edad': edad,
      'telefono': telefono?.trim(),
      'es_titular': esTitular,
    };
  }
}

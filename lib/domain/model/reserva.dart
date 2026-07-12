enum ReservaEstado {
  pendiente,
  confirmada,
  cancelada,
  finalizada;

  String get apiValue => name;

  static ReservaEstado fromApi(String value) {
    return ReservaEstado.values.firstWhere(
      (estado) => estado.apiValue == value,
      orElse: () => throw FormatException(
        'Estado de reserva desconocido: $value',
      ),
    );
  }
}

class Reserva {
  const Reserva({
    required this.id,
    required this.codigo,
    required this.clienteId,
    required this.clienteNombre,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.numeroNoches,
    required this.cantidadAdultos,
    required this.cantidadNinos,
    required this.estado,
    required this.subtotal,
    required this.impuestos,
    required this.descuento,
    required this.total,
    required this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String codigo;
  final int clienteId;
  final String clienteNombre;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int numeroNoches;
  final int cantidadAdultos;
  final int cantidadNinos;
  final ReservaEstado estado;
  final double subtotal;
  final double impuestos;
  final double descuento;
  final double total;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      clienteId: json['cliente'] as int,
      clienteNombre: json['cliente_nombre'] as String,
      fechaEntrada: DateTime.parse(json['fecha_entrada'] as String),
      fechaSalida: DateTime.parse(json['fecha_salida'] as String),
      numeroNoches: json['numero_noches'] as int,
      cantidadAdultos: json['cantidad_adultos'] as int,
      cantidadNinos: json['cantidad_ninos'] as int,
      estado: ReservaEstado.fromApi(json['estado'] as String),
      subtotal: double.parse(json['subtotal'].toString()),
      impuestos: double.parse(json['impuestos'].toString()),
      descuento: double.parse(json['descuento'].toString()),
      total: double.parse(json['total'].toString()),
      observaciones: json['observaciones']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ReservaRequest {
  const ReservaRequest({
    required this.clienteId,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.cantidadAdultos,
    required this.cantidadNinos,
    required this.subtotal,
    required this.impuestos,
    required this.descuento,
    required this.total,
    this.observaciones,
  });

  final int clienteId;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int cantidadAdultos;
  final int cantidadNinos;
  final double subtotal;
  final double impuestos;
  final double descuento;
  final double total;
  final String? observaciones;

  Map<String, dynamic> toJson() {
    return {
      'cliente': clienteId,
      'fecha_entrada': _formatDate(fechaEntrada),
      'fecha_salida': _formatDate(fechaSalida),
      'cantidad_adultos': cantidadAdultos,
      'cantidad_ninos': cantidadNinos,
      'subtotal': subtotal.toStringAsFixed(2),
      'impuestos': impuestos.toStringAsFixed(2),
      'descuento': descuento.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'observaciones': observaciones,
    };
  }
}

String _formatDate(DateTime date) {
  return date.toIso8601String().split('T').first;
}

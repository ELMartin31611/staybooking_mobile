enum FacturaEstado {
  emitida,
  pagada,
  anulada;

  String get apiValue => name;

  String get label {
    return switch (this) {
      FacturaEstado.emitida => 'Emitida',
      FacturaEstado.pagada => 'Pagada',
      FacturaEstado.anulada => 'Anulada',
    };
  }

  static FacturaEstado fromApi(dynamic value) {
    return FacturaEstado.values.firstWhere(
      (item) => item.apiValue == value?.toString().toLowerCase(),
      orElse: () => FacturaEstado.emitida,
    );
  }
}

class Factura {
  const Factura({
    required this.id,
    required this.reservaId,
    required this.reservaCodigo,
    required this.clienteId,
    required this.clienteNombre,
    required this.numeroFactura,
    required this.fechaEmision,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.numeroNoches,
    required this.subtotal,
    required this.impuestos,
    required this.descuento,
    required this.total,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.descripcion,
    this.metodoPago,
  });

  final int id;
  final int reservaId;
  final String reservaCodigo;
  final int clienteId;
  final String clienteNombre;
  final String numeroFactura;
  final DateTime fechaEmision;
  final String? descripcion;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int numeroNoches;
  final double subtotal;
  final double impuestos;
  final double descuento;
  final double total;
  final String? metodoPago;
  final FacturaEstado estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get estaPagada => estado == FacturaEstado.pagada;
  bool get estaAnulada => estado == FacturaEstado.anulada;

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: _parseInt(json['id']),
      reservaId: _parseRelationId(json['reserva']),
      reservaCodigo: (json['reserva_codigo'] ?? '').toString(),
      clienteId: _parseRelationId(json['cliente']),
      clienteNombre: (json['cliente_nombre'] ?? '').toString(),
      numeroFactura: (json['numero_factura'] ?? '').toString(),
      fechaEmision: _parseDateTime(json['fecha_emision']),
      descripcion: _parseNullableString(json['descripcion']),
      fechaEntrada: _parseDateTime(json['fecha_entrada']),
      fechaSalida: _parseDateTime(json['fecha_salida']),
      numeroNoches: _parseInt(json['numero_noches']),
      subtotal: _parseDouble(json['subtotal']),
      impuestos: _parseDouble(json['impuestos']),
      descuento: _parseDouble(json['descuento']),
      total: _parseDouble(json['total']),
      metodoPago: _parseNullableString(json['metodo_pago']),
      estado: FacturaEstado.fromApi(json['estado']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _parseRelationId(dynamic value) {
  if (value is Map) {
    return _parseInt(value['id']);
  }

  return _parseInt(value);
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _parseDateTime(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

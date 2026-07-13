enum MetodoPago {
  efectivo,
  tarjeta,
  transferencia;

  String get apiValue => name;

  String get label {
    return switch (this) {
      MetodoPago.efectivo => 'Efectivo',
      MetodoPago.tarjeta => 'Tarjeta',
      MetodoPago.transferencia => 'Transferencia',
    };
  }

  static MetodoPago fromApi(dynamic value) {
    return MetodoPago.values.firstWhere(
      (item) => item.apiValue == value?.toString().toLowerCase(),
      orElse: () => MetodoPago.efectivo,
    );
  }
}

enum PagoEstado {
  pendiente,
  aprobado,
  rechazado;

  String get apiValue => name;

  String get label {
    return switch (this) {
      PagoEstado.pendiente => 'Pendiente',
      PagoEstado.aprobado => 'Aprobado',
      PagoEstado.rechazado => 'Rechazado',
    };
  }

  static PagoEstado fromApi(dynamic value) {
    return PagoEstado.values.firstWhere(
      (item) => item.apiValue == value?.toString().toLowerCase(),
      orElse: () => PagoEstado.pendiente,
    );
  }
}

class Pago {
  const Pago({
    required this.id,
    required this.reservaId,
    required this.reservaCodigo,
    required this.codigoTransaccion,
    required this.metodoPago,
    required this.monto,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.fechaPago,
    this.referencia,
    this.comprobanteUrl,
    this.observaciones,
  });

  final int id;
  final int reservaId;
  final String reservaCodigo;
  final String codigoTransaccion;
  final MetodoPago metodoPago;
  final double monto;
  final PagoEstado estado;
  final DateTime? fechaPago;
  final String? referencia;
  final String? comprobanteUrl;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get estaAprobado => estado == PagoEstado.aprobado;
  bool get estaPendiente => estado == PagoEstado.pendiente;
  bool get fueRechazado => estado == PagoEstado.rechazado;

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: _parseInt(json['id']),
      reservaId: _parseRelationId(json['reserva']),
      reservaCodigo: (json['reserva_codigo'] ?? '').toString(),
      codigoTransaccion: (json['codigo_transaccion'] ?? '').toString(),
      metodoPago: MetodoPago.fromApi(json['metodo_pago']),
      monto: _parseDouble(json['monto']),
      estado: PagoEstado.fromApi(json['estado']),
      fechaPago: _parseNullableDateTime(json['fecha_pago']),
      referencia: _parseNullableString(json['referencia']),
      comprobanteUrl: _parseNullableString(json['comprobante_url']),
      observaciones: _parseNullableString(json['observaciones']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }
}

class PagoRequest {
  const PagoRequest({
    required this.reservaId,
    required this.metodoPago,
    required this.monto,
    this.estado = PagoEstado.pendiente,
    this.referencia,
    this.comprobanteUrl,
    this.observaciones,
  });

  final int reservaId;
  final MetodoPago metodoPago;
  final double monto;
  final PagoEstado estado;
  final String? referencia;
  final String? comprobanteUrl;
  final String? observaciones;

  Map<String, dynamic> toJson() {
    return {
      'reserva': reservaId,
      'metodo_pago': metodoPago.apiValue,
      'monto': monto.toStringAsFixed(2),
      'estado': estado.apiValue,
      if (_hasText(referencia)) 'referencia': referencia!.trim(),
      if (_hasText(comprobanteUrl)) 'comprobante_url': comprobanteUrl!.trim(),
      if (_hasText(observaciones)) 'observaciones': observaciones!.trim(),
    };
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

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

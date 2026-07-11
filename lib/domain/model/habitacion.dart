class Habitacion {
  final int id;
  final int? hotelId;
  final int? tipoHabitacionId;
  final String numero;
  final int piso;
  final String descripcion;
  final String estado;
  final bool disponible;
  final Map<String, dynamic> raw;

  const Habitacion({
    required this.id,
    this.hotelId,
    this.tipoHabitacionId,
    required this.numero,
    required this.piso,
    required this.descripcion,
    required this.estado,
    required this.disponible,
    required this.raw,
  });

  factory Habitacion.fromJson(Map<String, dynamic> json) {
    return Habitacion(
      id: _toInt(json['id']) ?? 0,
      hotelId: _readId(
        json['hotel'] ?? json['hotel_id'],
      ),
      tipoHabitacionId: _readId(
        json['tipo_habitacion'] ??
            json['tipo_habitacion_id'] ??
            json['tipoHabitacion'],
      ),
      numero:
          (json['numero'] ?? json['numero_habitacion'] ?? json['codigo'] ?? '')
              .toString(),
      piso: _toInt(
            json['piso'] ?? json['numero_piso'],
          ) ??
          0,
      descripcion:
          (json['descripcion'] ?? json['description'] ?? '').toString(),
      estado: (json['estado'] ?? 'DISPONIBLE').toString(),
      disponible: _toBool(
        json['disponible'] ??
            json['esta_disponible'] ??
            json['is_available'] ??
            true,
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int? _readId(dynamic value) {
    if (value is Map) {
      return _toInt(value['id']);
    }

    return _toInt(value);
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' || text == '1' || text == 'si' || text == 'sí';
  }
}

class PaginatedHabitaciones {
  final int count;
  final String? next;
  final String? previous;
  final List<Habitacion> results;

  const PaginatedHabitaciones({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedHabitaciones.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['results'];

    final results = data is List
        ? data
            .whereType<Map>()
            .map(
              (item) => Habitacion.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <Habitacion>[];

    return PaginatedHabitaciones(
      count: int.tryParse(json['count']?.toString() ?? '') ?? results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}

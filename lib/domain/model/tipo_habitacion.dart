class TipoHabitacion {
  final int id;
  final int? hotelId;
  final String nombre;
  final String descripcion;
  final int capacidad;
  final String estado;

  const TipoHabitacion({
    required this.id,
    this.hotelId,
    required this.nombre,
    required this.descripcion,
    required this.capacidad,
    required this.estado,
  });

  factory TipoHabitacion.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotel'] ?? json['hotel_id'];

    return TipoHabitacion(
      id: _toInt(json['id']) ?? 0,
      hotelId: hotel is Map ? _toInt(hotel['id']) : _toInt(hotel),
      nombre:
          (json['nombre'] ?? json['name'] ?? 'Tipo de habitación').toString(),
      descripcion:
          (json['descripcion'] ?? json['description'] ?? '').toString(),
      capacidad: _toInt(
            json['capacidad'] ??
                json['capacidad_personas'] ??
                json['capacidad_maxima'],
          ) ??
          0,
      estado: (json['estado'] ?? 'ACTIVO').toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}

class PaginatedTiposHabitacion {
  final int count;
  final String? next;
  final String? previous;
  final List<TipoHabitacion> results;

  const PaginatedTiposHabitacion({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedTiposHabitacion.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['results'];

    final results = data is List
        ? data
            .whereType<Map>()
            .map(
              (item) => TipoHabitacion.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <TipoHabitacion>[];

    return PaginatedTiposHabitacion(
      count: int.tryParse(json['count']?.toString() ?? '') ?? results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}

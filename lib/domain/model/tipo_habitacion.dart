class TipoHabitacion {
  const TipoHabitacion({
    required this.id,
    this.hotelId,
    required this.nombre,
    required this.descripcion,
    required this.capacidadAdultos,
    required this.capacidadNinos,
    required this.capacidadTotal,
    required this.tamanoM2,
    required this.precioBase,
    required this.estado,
  });

  final int id;
  final int? hotelId;
  final String nombre;
  final String descripcion;
  final int capacidadAdultos;
  final int capacidadNinos;
  final int capacidadTotal;
  final double tamanoM2;
  final double precioBase;
  final String estado;

  int get capacidad => capacidadTotal;

  factory TipoHabitacion.fromJson(
    Map<String, dynamic> json,
  ) {
    final hotel = json['hotel'] ?? json['hotel_id'];

    return TipoHabitacion(
      id: _toInt(json['id']) ?? 0,
      hotelId: hotel is Map ? _toInt(hotel['id']) : _toInt(hotel),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      capacidadAdultos: _toInt(
            json['capacidad_adultos'],
          ) ??
          0,
      capacidadNinos: _toInt(
            json['capacidad_ninos'],
          ) ??
          0,
      capacidadTotal: _toInt(
            json['capacidad_total'] ??
                json['capacidad'] ??
                json['capacidad_personas'],
          ) ??
          0,
      tamanoM2: _toDouble(json['tamano_m2']),
      precioBase: _toDouble(json['precio_base']),
      estado: (json['estado'] ?? 'ACTIVO').toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PaginatedTiposHabitacion {
  const PaginatedTiposHabitacion({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<TipoHabitacion> results;

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
      count: int.tryParse(
            json['count']?.toString() ?? '',
          ) ??
          results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}
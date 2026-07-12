class Cama {
  final int id;
  final String nombre;
  final String descripcion;
  final int capacidad;
  final String estado;
  final Map<String, dynamic> raw;

  const Cama({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.capacidad,
    required this.estado,
    required this.raw,
  });

  factory Cama.fromJson(Map<String, dynamic> json) {
    return Cama(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ??
              json['tipo'] ??
              json['tipo_cama'] ??
              json['name'] ??
              'Cama')
          .toString(),
      descripcion:
          (json['descripcion'] ?? json['description'] ?? '').toString(),
      capacidad: _toInt(
            json['capacidad'] ?? json['capacidad_personas'] ?? json['personas'],
          ) ??
          1,
      estado: (json['estado'] ?? 'ACTIVO').toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}

class PaginatedCamas {
  final int count;
  final String? next;
  final String? previous;
  final List<Cama> results;

  const PaginatedCamas({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedCamas.fromJson(Map<String, dynamic> json) {
    final data = json['results'];

    final results = data is List
        ? data
            .whereType<Map>()
            .map(
              (item) => Cama.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <Cama>[];

    return PaginatedCamas(
      count: int.tryParse(json['count']?.toString() ?? '') ?? results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}
